from tkinter.ttk import Frame, Treeview
from tkinter import *
from enum import Enum

from src.Table import Table, TableWithAddition


class TableView:
    def __init__(self, table, table_control):
        self.table = table
        self.tab = Frame(table_control)
        self.tree = None
        self.extra_window = None
        self.entry_dict = None

    def create_tree_views(self):
        if self.tree:
            self.tree.destroy()

        scrollbarx = Scrollbar(self.tab, orient=HORIZONTAL)
        scrollbary = Scrollbar(self.tab, orient=VERTICAL)

        self.tree = Treeview(self.tab, columns=self.table.columns,
                             height=400, selectmode="extended",
                             yscrollcommand=scrollbary.set, xscrollcommand=scrollbarx.set)
        scrollbary.config(command=self.tree.yview)
        scrollbary.pack(side=RIGHT, fill=Y)
        scrollbarx.config(command=self.tree.xview)
        scrollbarx.pack(side=BOTTOM, fill=X)

        for i in self.table.columns:
            self.tree.heading(i, text=i, anchor=CENTER)  # anchor=W

        self.tree.column('#0', stretch=NO, minwidth=0, width=0)

        for i in range(1, len(self.table.columns)):
            self.tree.column('#' + str(i), stretch=NO, minwidth=150, width=200)

        data = self.table.get_table()
        for i in data:
            self.tree.insert("", 0, values=i)
        self.tree.pack()

    class StateRadioButton(Enum):
        ADD = 1
        UPDATE = 2
        DELETE = 3
        SEARCH = 4
        CLEAR = 5

    def create_extra_window(self):
        self.extra_window = Toplevel(self.tab)
        self.extra_window.title("Изменение данных файла")
        w = self.tab.winfo_screenwidth()
        h = self.tab.winfo_screenheight()
        w = w // 2 + 150
        h = h // 2 - 300
        self.extra_window.geometry('+{}+{}'.format(w, h))
        self.extra_window.resizable(False, False)

        for i, column in enumerate(self.table.columns):  # except ID
            lbl = Label(self.extra_window, text=column)
            lbl.grid(column=0, row=i + 2, pady=10)
            txt = Entry(self.extra_window, width=25)
            txt.grid(column=1, row=i + 2, columnspan=2, pady=10, padx=10)
            self.entry_dict[column] = txt
        # self.entry_dict['Код книги'].configure(state="disable")
        var_radio_buttons = IntVar()
        var_radio_buttons.set(1)
        rad1 = Radiobutton(self.extra_window, text='Add', variable=var_radio_buttons, value=self.StateRadioButton.ADD.value)
        rad2 = Radiobutton(self.extra_window, text='Update', variable=var_radio_buttons, value=self.StateRadioButton.UPDATE.value)
        rad3 = Radiobutton(self.extra_window, text='Delete', variable=var_radio_buttons, value=self.StateRadioButton.DELETE.value)
        rad4 = Radiobutton(self.extra_window, text='Search', variable=var_radio_buttons, value=self.StateRadioButton.SEARCH.value)

        rad1.grid(column=0, row=0, pady=10)
        rad2.grid(column=1, row=0, pady=10)
        rad3.grid(column=2, row=0, pady=10)
        rad4.grid(column=0, row=1, padx=23, sticky='w')

        button = Button(self.extra_window, text="OK", width=40,
                        command=lambda: self.perform_operation(var_radio_buttons.get(), self.process_data()))
        button.grid(column=0, row=8, columnspan=3, padx=10, pady=30)

    def process_data(self) -> tuple:
        result = []
        for key in self.entry_dict:
            value = self.entry_dict[key].get()
            if value.isdigit():
                result.append(int(value))
            else:
                result.append()
        return tuple(result)

    def perform_operation(self, state_radio_button: int, *parametres):
        if state_radio_button == self.StateRadioButton.ADD:
            self.table.insert(parametres)
        elif state_radio_button == self.StateRadioButton.UPDATE:
            self.table.update_record(parametres)
        elif state_radio_button == self.StateRadioButton.DELETE:
            if parametres[0].isdigit():
                self.table.delete_record(parametres)
            else:
                self.table.delete_by_address(parametres)
        elif state_radio_button == self.StateRadioButton.SEARCH:
            if self.table.__class__.__name__ == "TableWithAddition":
                self.table.search_by_address(parametres)
            elif self.table.__class__.__name__ == "Table":
                pass

    def show(self):
        self.create_tree_views()
        Button(self.tab, text="Change", command=self.create_extra_window)