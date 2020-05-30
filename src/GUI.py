from tkinter import *
from tkinter import messagebox as mb, ttk
from src.DatabaseOperations import DatabaseOperations


# TODO если база данных имеется, вывести содержимое при запуске
class GUI:
    def __init__(self):
        self.root = None
        self.main_menu = None
        self.database_operations = DatabaseOperations()
        self.tab_control = None

    def create_root(self):
        self.root = Tk()
        self.root.title("database")
        w = 640
        h = 420
        sw = self.root.winfo_screenwidth()
        sh = self.root.winfo_screenheight()
        x = (sw - w) / 2
        y = (sh - h) / 2
        self.root.geometry('%dx%d+%d+%d' % (w, h, x, y))
        self.root.resizable(False, False)

        self.main_menu = Menu(self.root)
        self.main_menu.add_command(label='Create database', state='disabled', command=
            self.show_fail_of_db_operations(self.database_operations.create_database, "Database already exists"))

        self.main_menu.add_command(label='Delete database', state='disabled', command=
                self.show_fail_of_db_operations(self.database_operations.drop_database, "Database does not exists"))

        delete_menu = Menu(self.main_menu, tearoff=0)
        delete_menu.add_command(label='consumers')
        delete_menu.add_command(label='suppliers')
        delete_menu.add_command(label='details')
        delete_menu.add_command(label='orders')
        delete_menu.add_command(label='all tables', command=
            self.show_fail_of_db_operations(self.database_operations.truncate_all_tables, "Database does not exists"))

        self.main_menu.add_cascade(label='Truncate..', menu=delete_menu, state='disabled')

        self.root.config(menu=self.main_menu)
        sign_in_button = Button(self.root, text='Sign in',
                                command=lambda: self.postgres_authentication()).pack(anchor=CENTER)

        self.root.protocol('WM_DELETE_WINDOW', lambda:  self.close_root())

    def create_tab_control(self):
        self.tab_control = ttk.Notebook(self.root)
        self.tab_control.pack(expand=1, fill='both')

    def close_root(self):
        self.database_operations.close_all()
        self.root.destroy()

    def show_fail_of_db_operations(self, operation, error_message):
        def wrapper(*args):
            if not operation(*args):
                mb.showerror("ERROR", error_message)

        return wrapper

    def create_tree_views(self, tab):
        frame = Frame(tab, width=500)
        headers = ['id', 'name', 'address']
        frame.pack(side=TOP)
        scrollbarx = Scrollbar(frame, orient=HORIZONTAL)
        scrollbary = Scrollbar(frame, orient=VERTICAL)

        tree_consumers = ttk.Treeview(frame,
                             columns=headers,
                             height=400, selectmode="extended",
                             yscrollcommand=scrollbary.set, xscrollcommand=scrollbarx.set)
        scrollbary.config(command=tree_consumers.yview)
        scrollbary.pack(side=RIGHT, fill=Y)
        scrollbarx.config(command=tree_consumers.xview)
        scrollbarx.pack(side=BOTTOM, fill=X)

        for i in headers:
            tree_consumers.heading(i, text=i, anchor=CENTER)  # anchor=W

        tree_consumers.column('#0', stretch=NO, minwidth=0, width=0)

        for i in range(1, 3):
            tree_consumers.column('#' + str(i), stretch=NO, minwidth=150, width=200)

        tree_consumers.pack()

    def add_tab(self):
        tab = ttk.Frame(self.tab_control)
        def create_extra_window():
            self.extra_window = Toplevel(tab)
            self.extra_window.title("Изменение данных файла")
            w = tab.winfo_screenwidth()
            h = tab.winfo_screenheight()
            w = w // 2 + 150
            h = h // 2 - 300
            self.extra_window.geometry('+{}+{}'.format(w, h))
            self.extra_window.resizable(False, False)

            for i, column in enumerate(['id', 'name', 'address']):  # except ID
                lbl = Label(self.extra_window, text=column)
                lbl.grid(column=0, row=i + 2, pady=10)
                txt = Entry(self.extra_window, width=25)
                txt.grid(column=1, row=i + 2, columnspan=2, pady=10, padx=10)

            # self.entry_dict['Код книги'].configure(state="disable")
            self.var_radio_buttons = IntVar()
            self.var_radio_buttons.set(1)
            rad1 = Radiobutton(self.extra_window, text='Add', variable=self.var_radio_buttons, value=1)
            rad2 = Radiobutton(self.extra_window, text='Update', variable=self.var_radio_buttons, value=2)
            rad3 = Radiobutton(self.extra_window, text='Delete', variable=self.var_radio_buttons, value=3)
            rad4 = Radiobutton(self.extra_window, text='Search', variable=self.var_radio_buttons, value=4)

            rad1.grid(column=0, row=0, pady=10)
            rad2.grid(column=1, row=0, pady=10)
            rad3.grid(column=2, row=0, pady=10)
            rad4.grid(column=0, row=1, padx=23, sticky='w')

            button = Button(self.extra_window, text="Изменить", width=40)
            button.grid(column=0, row=8, columnspan=3, padx=10, pady=30)

        Button(tab, text="Change..", command=create_extra_window).pack(anchor=NW)
        self.create_tree_views(tab)
        self.tab_control.add(tab, text="consumers")


    def postgres_authentication(self):
        def check():
            if not self.database_operations.init_connection(username_entry.get(), password_entry.get()):
                mb.showerror("Error authentication", "Wrong username or password")
                extra_window.focus_set()
            else:

                extra_window.destroy()
                self.main_menu.entryconfig('Create database', state='normal')
                self.main_menu.entryconfig('Delete database', state='normal')
                self.main_menu.entryconfig('Truncate..', state='normal')
                self.create_tab_control()
                self.add_tab()

        extra_window = Toplevel(self.root)
        extra_window.title('Sign in')
        w = 185
        h = 70
        sw = extra_window.winfo_screenwidth()
        sh = extra_window.winfo_screenheight()
        x = (sw - w) / 2
        y = (sh - h) / 2
        extra_window.geometry('%dx%d+%d+%d' % (w, h, x, y))
        extra_window.resizable(False, False)

        Label(extra_window, text='Username').grid(row=0, column=0)
        username_entry = Entry(extra_window)
        username_entry.insert(END, 'postgres')
        username_entry.grid(row=0, column=1)

        Label(extra_window, text='Password').grid(row=1, column=0)
        password_entry = Entry(extra_window, show='*')
        password_entry.insert(END, 'SQL0!')
        password_entry.grid(row=1, column=1)

        button_sign_in = Button(extra_window, text='Sign in', command=check)
        button_sign_in.grid(row=3, column=0, columnspan=2)


if __name__ == '__main__':
    gui = GUI()
    gui.create_root()
    gui.root.mainloop()
