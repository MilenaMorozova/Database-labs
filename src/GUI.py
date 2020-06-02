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
        self.table_views = []
        self.sign_in_button = None

    def create_root(self):
        self.root = Tk()
        self.root.title("database")
        w = 700
        h = 450
        sw = self.root.winfo_screenwidth()
        sh = self.root.winfo_screenheight()
        x = (sw - w) / 2
        y = (sh - h) / 2
        self.root.geometry('%dx%d+%d+%d' % (w, h, x, y))
        self.root.resizable(False, False)

        self.main_menu = Menu(self.root)

        def create_database():
            if not self.database.create_database():
                mb.showerror("Create database", "Database already exist")
            self.create_tab_control()
            if not self.table_views:
                for i, table in enumerate(self.database.tables):
                    temp = TableView(table, self.tab_control)
                    self.table_views.append(temp)
                    temp.show()

        self.main_menu.add_command(label='Create database', state='disabled', command=create_database)

        def delete_database():
            if self.database.drop_database():
                self.tab_control.destroy()
                self.tab_control = None
                self.table_views.clear()
            else:
                mb.showerror("Delete database", "Database does not exist")

        self.main_menu.add_command(label='Delete database', state='disabled', command=delete_database)

        def truncate_all():
            if not self.database.truncate_all_tables():
                mb.showerror("Truncate all tables", "Database does not exist")
            else:
                for table_view in self.table_views:
                    table_view.create_tree_views()

        self.main_menu.add_command(label='Truncate all tables', state='disabled',
                                   comman=truncate_all)

        self.root.config(menu=self.main_menu)
        self.sign_in_button = Button(self.root, text='Sign in',
                                command=lambda: self.postgres_authentication())
        self.sign_in_button.pack(anchor=CENTER)

        def close_root():
            self.database.close_all()
            self.root.destroy()

        self.root.protocol('WM_DELETE_WINDOW', close_root)

    def create_tab_control(self):
        if self.tab_control is None:
            self.tab_control = ttk.Notebook(self.root)
            self.tab_control.pack(expand=1, fill='both')

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
                self.create_tab_control()
                if self.database.is_exists:
                    for i, table in enumerate(self.database.tables):
                        temp = TableView(table, self.tab_control)
                        self.table_views.append(temp)
                        temp.show()

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
        password_entry.grid(row=1, column=1)

        button_sign_in = Button(extra_window, text='Sign in', command=check)
        button_sign_in.grid(row=3, column=0, columnspan=2)


if __name__ == '__main__':
    gui = GUI()
    gui.create_root()
    gui.root.mainloop()
