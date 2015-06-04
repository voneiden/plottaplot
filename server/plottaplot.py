from autobahn.asyncio.websocket import WebSocketServerProtocol, WebSocketServerFactory
import json
import os
import base64
import hashlib
import redis
# Server secret
SECRET = 'pvjNETKbiC7LfjHkv2tsSg=='

HOST = '127.0.0.1'
PORT = 6379
PASSWORD = 'testing'
DBID = 0

db = redis.StrictRedis(host=HOST, port=PORT, password=PASSWORD, db=DBID, decode_responses=True)

def generate_dynamic_salt():
    return base64.b64encode(os.urandom(16)).decode('utf8')

def generate_static_salt(username):
    return base64.b64encode(hashlib.sha256((username + SECRET).encode("utf8")).digest()).decode("utf8")

class PlottaPlotProtocol(WebSocketServerProtocol):

    def onConnect(self, request):
        print("Client connecting: {0}".format(request.peer))

    def onOpen(self):
        print("WebSocket connection open.")

    def onMessage(self, payload, is_binary):
        if is_binary:
            print("Error: don't accept binary")
            self.send(False)
            return

        # echo back message verbatim
        try:
            data = json.loads(payload.decode('utf8'))
        except ValueError:
            print("Error, unable to load json")
            self.send(False)
            return

        request = data.get("request", False)

        if not request:
            self.send(False)
            return

        if request == "login_salts":
            user = data.get("user", False)
            if not user:
                return self.send(reason="bad protocol")
            else:
                key = "{user}:dynamic_salt".format(user=user)
                dynamic_salt = generate_dynamic_salt()
                db.set(key, dynamic_salt)
                db.expire(key, 10)
                return self.send({'static_salt': generate_static_salt(user), 'dynamic_salt': dynamic_salt})

        elif request == "register":
            user = data.get("user", False)
            password = data.get("pass", False)
            if not user or not password:
                return self.send(reason="bad protocol")

            db.set("{user}:pass".format(user=user), password)

            self.send(data=True)
        # Make two commands, push and pull (both commands requiring login auth)

        elif request == "login":
            user = data.get("user", False)
            password = data.get("pass", False)
            if not user or not password:
                return self.send(reason="bad protocol")

            real_password = db.get("{user}:pass".format(user=user))
            dynamic_salt = db.get("{user}:dynamic_salt".format(user=user))

            print("Got real password", real_password)
            if real_password is None or dynamic_salt is None:
                return self.send(reason="login failed")

            if hashlib.sha256((real_password + dynamic_salt).encode("utf8")).hexdigest() == password:
                key = "{user}:session".format(user=user)
                db.set(key, generate_dynamic_salt())
                db.expire(key, 86400)
            else:
                print("Mismatch")
                print (hashlib.sha256((real_password + dynamic_salt).encode("utf8")).hexdigest())
                print(password)


    def onClose(self, wasClean, code, reason):
        print("WebSocket connection closed: {0}".format(reason))

    def send(self, data=False, reason=None):
        """

        :type data: bool, dict
        """
        if data is False:
            data = {'result': False, 'reason': reason}
        elif data is True:
            data = {'result': True, 'reason': reason}
        else:
            assert isinstance(data, dict)
            if data.get('result', None) is None:
                data['result'] = True

        self.sendMessage(json.dumps(data).encode("utf8"))


if __name__ == '__main__':
    import asyncio

    factory = WebSocketServerFactory("ws://localhost:9000", debug=False)
    factory.protocol = PlottaPlotProtocol

    loop = asyncio.get_event_loop()
    coro = loop.create_server(factory, '127.0.0.1', 9000)
    server = loop.run_until_complete(coro)

    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.close()
        loop.close()