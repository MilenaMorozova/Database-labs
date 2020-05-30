import copy


class Table:
    def __init__(self, name, columns: list,  conn, cursor):
        self.name = name
        self.columns = columns
        self.conn = copy.deepcopy(conn)
        self.cursor = copy.deepcopy(cursor)

    def get_table(self) -> list:
        self.cursor.execute("SELECT get_{}()".format(self.name))
        result = self.cursor.fetchall()
        return result

    def clear_table(self):
        self.cursor.execute("SELECT clear_table({})".format(self.name))
        result = self.cursor.fetchall()

    def insert(self, *args):
        self.cursor.execute("SELECT insert_into_{}{}".format(self.name, args))  # ({}).format(*args)
        result = self.cursor.fetchall()

    def update_record(self, *args):
        self.cursor.execute("SELECT update_{}{}".format(self.name, args))
        result = self.cursor.fetchall()

    def delete_record(self):
        self.cursor.execute("SELECT delete_record_from_table({})".format(self.name))


class TableWithAddition(Table):
    def __init__(self, name, columns: list,  conn, cursor):
        super().__init__(name, columns, conn, cursor)

    def search_by_address(self, address: str):
        self.cursor.execute("SELECT search_{}_by_address({})".format(self.name, address))
        result = self.cursor.fetchall()

    def delete_by_address(self, address: str):
        self.cursor.execute("SELECT delete_from_{}_by_address({})".format(self.name, address))
