from tkinter.ttk import Frame, Treeview
from tkinter import *
from enum import Enum


class TableView:
    def __init__(self, table, table_control):
        self.table = table
        self.table_control = table_control
        self.tab = Frame(table_control)
        self.frame_buttons = Frame(self.tab)
        self.frame_tree_view = Frame(self.tab)
        self.tree = None
        self.scrollbarx = Scrollbar(self.frame_tree_view, orient=HORIZONTAL)
        self.scrollbary = Scrollbar(self.frame_tree_view, orient=VERTICAL)

    def create_tree_views(self, data: list = None):
        if self.tree:
            self.tree.destroy()
            self.tab.update()

        self.tree = Treeview(self.frame_tree_view, columns=self.table.columns,
                             height=400, selectmode="extended",
                             yscrollcommand=self.scrollbary.set, xscrollcommand=self.scrollbarx.set)

        self.scrollbary.config(command=self.tree.yview)
        self.scrollbary.pack(side=RIGHT, fill=Y)
        self.scrollbarx.config(command=self.tree.xview)
        self.scrollbarx.pack(side=BOTTOM, fill=X)

        for i in self.table.columns:
            self.tree.heading(i, text=i, anchor=CENTER)  # anchor=N

        self.tree.column('#0', stretch=NO, minwidth=0, width=0)
        for i in range(1, len(self.table.columns)):
            self.tree.column('#' + str(i), stretch=NO, minwidth=60, width=100)

        if data is None:
            data = self.table.get_records()

        # print("Данные таблицы", self.table.name, ':', data)
        if data:
            for i in data:
                self.tree.insert("", 0, values=i)
        self.tree.pack(side=BOTTOM)

    class Operations(Enum):
        ADD = 1
        UPDATE = 2
        DELETE_BY_ID = 3
        DELETE_BY_ADDRESS = 4
        SEARCH_BY_ADDRESS = 5

    def create_extra_window(self, function, columns: list = None, fill_entry=False):
        entry_dict = {}

        extra_window = Toplevel(self.tab)
        extra_window.title("Изменение данных файла")
        w = self.tab.winfo_screenwidth()
        h = self.tab.winfo_screenheight()
        w = w // 2 + 150
        h = h // 2 - 300
        extra_window.geometry('+{}+{}'.format(w, h))
        extra_window.resizable(False, False)

        if columns:
            for i, column in enumerate(columns):  # except ID
                lbl = Label(extra_window, text=column)
                lbl.grid(column=0, row=i + 2, pady=10)
                txt = Entry(extra_window, width=25)
                txt.grid(column=1, row=i + 2, columnspan=2, pady=10, padx=10)
                entry_dict[column] = txt

        if fill_entry:
            self.fill_entries(entry_dict)

        def update_tree():
            def process_data() -> tuple:
                result = []
                for key in entry_dict:
                    value = entry_dict[key].get()
                    if value.isdigit():
                        result.append(int(value))
                    else:
                        result.append(value)
                if len(result) == 1:
                    return result[0]
                return tuple(result)

            data = function(process_data())
            self.create_tree_views(data)

        button = Button(extra_window, text="OK", width=40,
                        command=lambda: update_tree())
        button.grid(column=0, row=8, columnspan=3, padx=10, pady=30)

    def fill_entries(self, entry_dict: dict):
        for key in entry_dict:
            entry_dict[key].config(state='disable')
        entry_dict['id'].config(state='normal')
        entry_dict['id'].bind('<Return>', lambda x: fill(entry_dict['id'].get()))

        def fill(record_id):
            result = self.table.get_record_by_id(record_id)
            result = result[0][0][1:-1].split(',')

            if self.table.name == 'orders':
                result = result[:-2]
            for column, value in zip(entry_dict, result):
                entry_dict[column].configure(state='normal')
                entry_dict[column].delete(0, END)
                entry_dict[column].insert(0, value)
            entry_dict['id'].configure(state='disabled')

    def create_function_window(self, operation):
        if operation == self.Operations.ADD:
            if self.table.name == 'orders':
                self.create_extra_window(self.table.insert, self.table.columns[1:-2])
            else:
                self.create_extra_window(self.table.insert, self.table.columns[1:])

        elif operation == self.Operations.UPDATE:
            if self.table.name == 'orders':
                self.create_extra_window(self.table.update_record, self.table.columns[:-2], True)
            else:
                self.create_extra_window(self.table.update_record, self.table.columns, True)

        elif operation == self.Operations.DELETE_BY_ID:
            self.create_extra_window(self.table.delete_record, [self.table.columns[0]])

        elif operation == self.Operations.DELETE_BY_ADDRESS:
            self.create_extra_window(self.table.delete_by_address, [self.table.columns[-1]])

        elif operation == self.Operations.SEARCH_BY_ADDRESS:
            self.create_extra_window(self.table.search_by_address, [self.table.columns[-1]])

    def show(self):
        add_button = Button(self.frame_buttons, text='Add record',
                            command=lambda: self.create_function_window(self.Operations.ADD))
        add_button.pack(side=LEFT)

        update_button = Button(self.frame_buttons, text='Update record',
                               command=lambda: self.create_function_window(self.Operations.UPDATE))
        update_button.pack(side=LEFT)

        delete_by_id_button = Button(self.frame_buttons, text='Delete record by id',
                                     command=lambda: self.create_function_window(self.Operations.DELETE_BY_ID))
        delete_by_id_button.pack(side=LEFT)

        def truncate():
            self.table.clear_table()
            self.create_tree_views()

        truncate_button = Button(self.frame_buttons, text='Truncate table', command=lambda: truncate())
        truncate_button.pack(side=LEFT)

        delete_by_address_button = Button(self.frame_buttons, text='Delete record by address',
                                          state='disabled' if self.table.__class__.__name__ == "Table" else 'normal',
                                        command=lambda: self.create_function_window(self.Operations.DELETE_BY_ADDRESS))
        delete_by_address_button.pack(side=LEFT)

        search_by_address_button = Button(self.frame_buttons, text='Search record by address',
                                         state='disabled' if self.table.__class__.__name__ == "Table" else 'normal',
                                         command=lambda: self.create_function_window(self.Operations.SEARCH_BY_ADDRESS))
        search_by_address_button.pack(side=LEFT)

        output_all_button = Button(self.frame_buttons, text='Output all', command=lambda: self.create_tree_views())
        output_all_button.pack(side=LEFT)

        self.create_tree_views()
        self.table_control.add(self.tab, text=self.table.name)
        self.frame_buttons.pack()
        self.frame_tree_view.pack()
