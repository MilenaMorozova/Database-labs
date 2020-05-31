from tkinter import *
from tkinter import messagebox as mb, ttk
from src.Database import Database

from src.TableView import TableView


class GUI:
    def __init__(self):
        self.root = None
        self.main_menu = None
        self.database = Database()
        self.tab_control = None
        self.tabs = []
        self.sign_in_button = None

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
        self.main_menu.add_command(label='Create database', state='disabled', command=self.create_database)

        self.main_menu.add_command(label='Delete database', state='disabled', command=
                self.show_fail_of_db_operations(self.database.drop_database, "Database does not exists"))
        self.main_menu.add_command(label='Truncate all tables', state='disabled',
                                   comman=self.database.truncate_all_tables)
        # delete_menu = Menu(self.main_menu, tearoff=0)
        # delete_menu.add_command(label='consumers')
        # delete_menu.add_command(label='suppliers')
        # delete_menu.add_command(label='details')
        # delete_menu.add_command(label='orders')
        # delete_menu.add_command(label='all tables', command=
        #     self.show_fail_of_db_operations(self.database.truncate_all_tables, "Database does not exists"))

        # self.main_menu.add_cascade(label='Truncate..', menu=delete_menu, state='disabled')

        self.root.config(menu=self.main_menu)
        self.sign_in_button = Button(self.root, text='Sign in',
                                command=lambda: self.postgres_authentication())
        self.sign_in_button.pack(anchor=CENTER)

        self.root.protocol('WM_DELETE_WINDOW', lambda:  self.close_root())

    def create_database(self):
        self.create_tab_control()
        self.show_fail_of_db_operations(self.database.create_database(), "Database already exists")
        if not self.tabs:
            temp = TableView(self.database.tables[0], self.tab_control)
            self.tabs.append(temp)
            temp.show()

    def create_tab_control(self):
        self.tab_control = ttk.Notebook(self.root)
        self.tab_control.pack(expand=1, fill='both')

    def close_root(self):
        self.database.close_all()
        self.root.destroy()

    def show_fail_of_db_operations(self, operation, error_message):
        def wrapper(*args):
            if not operation(*args):
                mb.showerror("ERROR", error_message)

        return wrapper

    def postgres_authentication(self):
        def check():
            if not self.database.init_connection(username_entry.get(), password_entry.get()):
                mb.showerror("Error authentication", "Wrong username or password")
                extra_window.focus_set()
            else:
                self.sign_in_button.destroy()
                extra_window.destroy()
                self.main_menu.entryconfig('Create database', state='normal')
                self.main_menu.entryconfig('Delete database', state='normal')
                self.main_menu.entryconfig('Truncate all tables', state='normal')

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
