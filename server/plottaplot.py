from autobahn.asyncio.websocket import WebSocketServerProtocol, WebSocketServerFactory
import json
import os
import base64


def generate_salt():
    return base64.b64encode(os.urandom(16)).decode('utf8')


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
            raise
            self.send(False)
            return

        request = data.get("request", False)

        if not request:
            self.send(False)
            return

        if request == "static_salt":
            self.send({'static_salt': generate_salt()})

        self.sendMessage("ok".encode("utf8"))

    def onClose(self, wasClean, code, reason):
        print("WebSocket connection closed: {0}".format(reason))

    def send(self, data=False):
        if not data:
            data = {'result': False}
        else:
            assert isinstance(data, dict)
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