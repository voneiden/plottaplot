import rom
import rom.util

rom.util.set_connection_settings(host='hammerjaw.redistogo.com', db=0, port=10214, password="4f8507b6890756e89016569fac19bc26")

class TextEntry(rom.Model):
    value = rom.Text(required=True)
    past = rom.OneToOne('TextEntry', on_delete='restrict')
    stamp = rom.Float(required=True)


class TitleEntry(rom.Model):
    value = rom.OneToMany('Place')
    past = rom.OneToOne('TitleEntry', on_delete='restrict')
    stamp = rom.Float(required=True)


class Being(rom.Model):
    name = rom.OneToOne('TextEntry', on_delete='restrict')
    titles = rom.OneToOne('TitleEntry', on_delete='restrict')


class Place(rom.Model):
    name = rom.OneToOne('TextEntry', on_delete='restrict')

if __name__ == "__main__":
    import time
    name = TextEntry(value="Sir Matti", stamp=time.time())
    name.save()

    

