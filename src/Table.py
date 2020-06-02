class Table:
    def __init__(self, name, columns: list, database):
        self.name = name
        self.columns = columns
        self.database = database

    def get_records(self) -> list:
        self.database.cursor.execute("SELECT * FROM get_{}()".format(self.name))
        result = self.database.cursor.fetchall()
        return result

    def get_record_by_id(self, record_id):
        self.database.cursor.execute("SELECT get_record_by_id('{}', {})".format(self.name, record_id))
        result = self.database.cursor.fetchall()
        return result

    def clear_table(self):
        self.database.cursor.execute("SELECT clear_table('{}')".format(self.name))
        result = self.database.cursor.fetchall()
        self.database.conn.commit()
        return result

    def insert(self, *args):
        self.database.cursor.execute("SELECT insert_into_{}{}".format(self.name, *args))
        self.database.conn.commit()
        return self.get_records()

    def update_record(self, *args):
        self.database.cursor.execute("SELECT update_{}{}".format(self.name, *args))
        self.database.conn.commit()
        return self.get_records()

    def delete_record(self, record_id: int):
        self.database.cursor.execute("SELECT delete_record_from_table({}, '{}')".format(record_id, self.name))
        self.database.conn.commit()
        return self.get_records()


class TableWithAddition(Table):
    def __init__(self, name, columns: list, cursor):
        super().__init__(name, columns, cursor)

    def search_by_address(self, address: str):
        self.database.cursor.execute("SELECT * FROM search_{}_by_address('{}')".format(self.name, address))
        result = self.database.cursor.fetchall()
        return result

    def delete_by_address(self, address: str):
        self.database.cursor.execute("SELECT delete_from_{}_by_address('{}')".format(self.name, address))
        self.database.conn.commit()
        return self.get_records()
