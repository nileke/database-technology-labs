#!/usr/bin/python
import pgdb
from sys import argv
import time
import datetime

class DBContext:
    """DBContext is a small interface to a database that simplifies SQL.
    Each function gathers the minimal amount of information required and executes the query."""

    def __init__(self): #PG-connection setup
        print("AUTHORS NOTE: If you submit faulty information here, I am not responsible for the consequences.")

        print "The idea is that you, the authorized database user, log in."
        print "Then the interface is available to employees whos should only be able to enter shipments as they are made."
        params = {'host':'localhost', 'user':raw_input("Username: "), 'database':'', 'password':raw_input("Password: ")}
        self.conn = pgdb.connect(**params)
        self.menu = ["Record a shipment","Show stock", "Show shipments", "Exit"]
        self.cur = self.conn.cursor()
    def print_menu(self):
        """Prints a menu of all functions this program offers.  Returns the numerical correspondant of the choice made."""
        for i,x in enumerate(self.menu):
            print("%i. %s"%(i+1,x))
        return self.get_int()

    def get_int(self):
        """Retrieves an integer from the user.
        If the user fails to submit an integer, it will reprompt until an integer is submitted."""
        while True:
            try:
                choice = int(input("Choose: "))
                if 1 <= choice <= len(self.menu):
                    return choice
                print("Invalid choice.")
            except (NameError,ValueError, TypeError,SyntaxError):
                print("That was not a number, genious.... :(")
 
    def makeShipments(self):
        
        # THESE INPUT LINES  ARE NOT GOOD ENOUGH    
        # YOU NEED TO TYPE CAST/ESCAPE THESE AND CATCH EXCEPTIONS
        try:
            CID = int(raw_input("customerID: "))
            SID = int(raw_input("shipment ID: "))
        except ValueError:
            print "Incorrect input. Only int allowed."
            return

        # Check CID and SID if they already exists
        try:
            self.check_customer(CID)
            self.check_shipment(SID)
        except Exception as e:
            print "Something went wrong. Error: " + str(e)
            print e
            return

        # Checks input and catches 
        try:
            Sisbn = pgdb.escape_string((raw_input("isbn: ").strip().upper()))
            validate_isbn(Sisbn)
        except (NameError, ValueError, TypeError, SyntaxError) as e:
            print "Error in input: " + str(e)
            return

        try:
            Sdate = pgdb.escape_string(raw_input("Ship date: ").strip())
            validate_date(Sdate)
        except ValueError as e:
            print e
            return

        Sdate = "%s %s+02" % (Sdate, time.strftime("%H:%M:%S", time.localtime()))
        print "Date and time for shipment registered: " + Sdate
        # THIS IS NOT RIGHT  YOU MUST FORM A QUERY THAT HELPS
        query = "SELECT stock FROM stock WHERE isbn='%s';" % Sisbn
        # print query
        # HERE YOU SHOULD start a transaction    
        
        # Not needed as creating the pgdb.Connection object starts a new transaction
        # We can commit in order to start a new fresh transaction
        # Source: http://www.pygresql.org/contents/pgdb/connection.html 
        self.conn.commit()

        #YOU NEED TO Catch exceptions ie bad queries
        try:
            self.cur.execute(query)
        except (pgdb.DatabaseError, pgdb.OperationalError, pgdb.DataError) as e:
            print "Error in query: " + e
            self.conn.rollback()    
            return          

        if self.cur.rowcount != 1:
            print "We don't have this book in our collection of books :("
            # self.conn.rollback() # Rollback to cancel transaction
            return

        #HERE YOU NEED TO USE THE RESULT OF THE QUERY TO TEST IF THER ARE 
        #ANY BOOKS IN STOCK 
        # YOU NEED TO CHANGE THIS TO SOMETHING REAL
        cnt = self.cur.fetchone();
        print cnt
        if cnt[0] < 1:
            print("No more books in stock :(")
            return
        else:
            print "We have the book in stock"
        

        query="""UPDATE stock SET stock=stock-1 WHERE isbn='%s';"""%(Sisbn)
        print query

        #YOU NEED TO Catch exceptions  and rollback the transaction
        try:
            self.cur.execute(query)
            print "stock decremented" 
        except (pgdb.DatabaseError, pgdb.OperationalError, pgdb.DataError) as e:
            print "Error during UPDATE. Doing rollback. Error raised: " + str(e)
            self.conn.rollback()
            return


        try:
            self.cur.execute(query)
        except (pgdb.DatabaseError, pgdb.OperationalError, pgdb.DataError) as e:
            print "Error. Doing rollback. Error raised: " + str(e)
            return

        # http://www.pygresql.org/contents/pgdb/module.html#pgdb.OperationalError
        # Creating query for inserting shipment to Shipments table
        query="""INSERT INTO shipments VALUES (%i, %i, '%s', to_timestamp('%s','YYYY-MM-DD HH24:MI:SS'));"""% (SID,CID,Sisbn,Sdate)
        print query

        #YOU NEED TO Catch exceptions and rollback the transaction
        try:
            self.cur.execute(query)
            print "shipment created" 
        except (pgdb.DatabaseError, pgdb.DataError, pgdb.OperationalError) as e:
            print "Error. Doing rollback." + str(e)
            self.conn.rollback()
            return

        # This ends the transaction (and starts a new one)    
        self.conn.commit()

    def showStock(self):
        query="""SELECT * FROM stock;"""
        print query
        try:
            self.cur.execute(query)
        except (pgdb.DatabaseError, pgdb.OperationalError):
            print "  Exception encountered while modifying table data." 
            self.conn.rollback ()
            return   
        self.print_answer()

    def showShipments(self):
        query="""SELECT * FROM shipments;"""
        print query
        try:
            self.cur.execute(query)
        except (pgdb.DatabaseError, pgdb.OperationalError):
            print "  Exception encountered while modifying table data." 
            self.conn.rollback ()
            return   
        self.print_answer()

    def exit(self):    
        self.cur.close()
        self.conn.close()
        exit()

    def print_answer(self):
        print("\n".join([", ".join([str(a) for a in x]) for x in self.cur.fetchall()]))

    # we call this below in the main function.
    def run(self):
        """Main loop.
        Will divert control through the DBContext as dictated by the user."""
        actions = [self.makeShipments, self.showStock, self.showShipments, self.exit]
        while True:
            try:
                actions[self.print_menu()-1]()
            except IndexError:
                print("Bad choice")
                continue

    def check_customer(self, CID):
        # Helper method that checks if customer exists in Customers otherwise adds them
        try:
            self.cur.execute("SELECT customer_id FROM customers WHERE customer_id=%s;" % CID)
        except (pgdb.DatabaseError, pgdb.OperationalError, pgdb.DataError) as e:
            raise e("Error in check_customer.")
        
        if self.cur.rowcount != 0:
            return
        
        print "Customer do not exist."

        query = "INSERT INTO customers (customer_id, first_name, last_name) VALUES (%s) ON CONFLICT (customer_id) DO NOTHING;" % (CID)
        try:
            self.cur.execute(query)
            print "Customer added to customers table. Please update first and last name."
        except (pgdb.DatabaseError, pgdb.OperationalError, pgdb.DataError) as e:
            raise e("Error in check_customer. Failed to add new customer. Error: " + str(e))

        return

    def check_shipment(self, SID):
        # Checks that shipment_id doesn't already excist in Shipments
        # Also catches pgdb-errors if they occurs in query 
        try:
            self.cur.execute("SELECT shipment_id FROM shipments WHERE shipment_id=%s;" % SID)
        except (pgdb.DatabaseError, pgdb.OperationalError, pgdb.DataError) as e:
            raise e("Error in check_shipment.")
       
        if self.cur.rowcount != 0:
            # print "Shipment ID already exists. Try a different shipment ID"
            raise ValueError("Shipment ID already exists. Try a different shipment ID")

        return

def validate_date(input_date):
    '''
    Validates date format and raises ValueError if incorrect format
    '''
    try:
        datetime.datetime.strptime(input_date, "%Y-%m-%d")
    except ValueError:
        raise ValueError("Incorrect date format. Should be YYYY-MM-DD.")

def validate_isbn(isbn):
    '''
    Validates isbn format and raises ValueError if not correct.
    '''
    if len(isbn) != 10:
        raise ValueError("Incorrect length of isbn input. Must be 10 characters")
    return

if __name__ == "__main__":
    db = DBContext()
    db.run()
