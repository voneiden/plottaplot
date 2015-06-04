import redis
"""

High level objects
------------------

Being - Some sort of life form
Place - Some sort of location
Event - Some sort of storyline event


Database format

{username}:Being
                .pks - set of all pks
                .pk  - pk counter
                :{pk}
                     :stamps
                            .{attribute name} - list of all stamps associated with the attribute
                     .stamps - list of all timestamps associated with this object
                     :{stamp}
                             .{attribute value(s)}



"""


connection = False
""":type : redis.StrictRedis"""


class Session(object):
    def __init__(self, user, **kwargs):
        self.user = user
        self.stamp = kwargs.get("stamp", "13370606")



def connect(host='127.0.0.1', port=6379, password='testing', db=0):
    global connection
    connection = redis.StrictRedis(host=host, port=port, password=password, db=db, decode_responses=True)



class Model(object):
    pk = None

    class RList(list):
        def append(self, p_object):
            pass

        def index(self, value, **kwargs):
            pass

        def remove(self, x):
            pass

    def __init__(self, session, **kwargs):
        print(dir(self))
        print(self.__class__.__name__)

        pk = kwargs.get("pk")
        if pk is None:
            pk = connection.incr("{user}:{cls}.pk".format(user=session.user, cls=self.__class__.__name__))
            connection.sadd("{username}:{cls}.pks".format(username=session.user, cls=self.__class__.__name__), pk)
            pass

        self.pk = pk
        self.session = session

        """
        for attribute in dir(self):
            if attribute[0] == "_" or not isinstance(getattr(self, attribute), type) or attribute == "NotFound":
                continue

            print("Valid attribute", attribute)
            mode = getattr(self, attribute)
            if mode == str or mode == int:
        """

    def __getattribute__(self, name):
        attribute_type = object.__getattribute__(self, name)
        if name[0] == "_" or not isinstance(attribute_type, type) or name == "NotFound":
            return object.__getattribute__(self, name)

        else:
            print("get", name)
            global connection
            if isinstance(connection, redis.StrictRedis):

                # Get all stamps associated with the attribute name
                stamps = connection.zrange("{username}:{cls}:{pk}:stamps.{name}".format(username=self.session.user,
                                                                                        cls=self.__class__.__name__,
                                                                                        pk=self.pk,
                                                                                        name=name), 0, -1)

                # No stamps found, attribute not defined
                if len(stamps) == 0:
                    raise AttributeError

                # Convert stamps to ints (for sorting)
                #stamps = [int(stamp) for stamp in stamps]

                print("Got stamps", stamps)
                stamp = self.session.stamp
                try:
                    # Check if stamp already exists
                    stamps.index(stamp)
                except ValueError:
                    # Otherwise add it, sort, and get the last
                    stamps.append(stamp)
                    stamps.sort()
                    index = stamps.index(stamp)

                    # Last doesn't exist, attribute not defined
                    if index == 0:
                        raise AttributeError
                    else:
                        stamp = stamps[index - 1]

                print("Attribute defined at stamp", stamp)
                # TODO figure out the nearest matching year and fetch the value
                key = "{username}:{cls}:{pk}:{stamp}.{name}".format(username=self.session.user,
                                                                    cls=self.__class__.__name__,
                                                                    pk=self.pk,
                                                                    stamp=stamp,
                                                                    name=name)
                if attribute_type == str or attribute_type == int:
                    return connection.get(key)

                elif attribute_type == list:
                    return self.RList(connection.lrange(key, 0, -1))

                else:
                    raise NotImplemented
            else:
                raise ConnectionError


    def __setattr__(self, name, value):
        print("set", name, value)
        try:
            attribute_type = object.__getattribute__(self, name)
        except AttributeError:
            attribute_type = None
        if name[0] == "_" or not isinstance(attribute_type, type) or name == "NotFound":
            return object.__setattr__(self, name, value)
        else:
            print("Updating", name)
            # Insert new stamp reference
            connection.zadd("{username}:{cls}:{pk}:stamps.{name}".format(username=self.session.user,
                                                                         cls=self.__class__.__name__,
                                                                         pk=self.pk,
                                                                         name=name),
                            0,
                            self.session.stamp)

            key = "{username}:{cls}:{pk}:{stamp}.{name}".format(username=self.session.user,
                                                                cls=self.__class__.__name__,
                                                                pk=self.pk,
                                                                stamp=self.session.stamp,
                                                                name=name)
            if attribute_type == str or attribute_type == int:
                connection.set(key, value)
            elif attribute_type == list:
                connection.l
            else:
                raise NotImplemented



    @classmethod
    def get(cls, session, pk):
        assert isinstance(session.user, str)
        assert isinstance(pk, int)

        global connection
        if isinstance(connection, redis.StrictRedis):
            if connection.sismember("{username}:{cls}.pks".format(username=session.user, cls=cls.__name__), pk):
                pass
            else:
                raise cls.NotFound()

        else:
            raise ConnectionError


    @classmethod
    def all(cls, session):
        assert isinstance(session.user, str)

        global connection
        if isinstance(connection, redis.StrictRedis):
            set_members = connection.smembers("{username}:{cls}.pks".format(username=session.user, cls=cls.__name__))
            print("Set members", set_members)
            results = []
            for member in set_members:
                print("Member found", member)
                results.append(cls(session, pk=member))

            return results

        else:
            raise ConnectionError

    @classmethod
    def create(cls, session, **kwargs):
        assert isinstance(session.user, str)
        global connection

        if isinstance(connection, redis.StrictRedis):
            new = cls(**kwargs)
            new.save()
            #new.pk = connection.incr("{username}:{cls}.pk".format(username=username, cls=cls.__name__))
            return new


        else:
            raise ConnectionError

    class NotFound(Exception):
        pass


class Being(Model):
    name = str
    born = float
    died = float
    titles = list



class User(Model):
    pass


if __name__ == "__main__":
    connect()
    session = Session('voneiden')

    try:
        Being.get(session, 0)
    except Being.NotFound:
        print("Not found, OK")

    all = Being.all(session)

    print("Got", all)

    print("His name is", all[0].name)

    #new = Being(session)
    #new.name = "Sir Matti"
