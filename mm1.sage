'''
Simple script for an MM1 queue
'''

import random
import csv

#define a class called 'Customer'
class Customer:
    def __init__(self,arrival_date,service_start_date,service_time):
        self.arrival_date=arrival_date
        self.service_start_date=service_start_date
        self.service_time=service_time
        self.service_end_date=self.service_start_date+self.service_time
        self.wait=self.service_start_date-self.arrival_date

#a simple function to sample from negative exponential
def neg_exp(lambd):
    return random.expovariate(lambd)

@parallel
def mm1sim(lambd=False,mu=False,simulation_time=False,seed=random.random()):
    """
    This is the main function to call to simulate an MM1 queue.
    """
    random.seed()  # Need to reset random seed

    #Initialise clock
    t=0

    #Initialise empty list to hold all data
    Customers=[]

    #----------------------------------
    #The actual simulation happens here:
    while t<simulation_time:

        #calculate arrival date and service time for new customer
        if len(Customers)==0:
            arrival_date=neg_exp(lambd)
            service_start_date=arrival_date
        else:
            arrival_date+=neg_exp(lambd)
            service_start_date=max(arrival_date,Customers[-1].service_end_date)
        service_time=neg_exp(mu)

        #create new customer
        Customers.append(Customer(arrival_date,service_start_date,service_time))

        #increment clock till next end of service
        t=arrival_date
    #----------------------------------

    #calculate summary statistics
    Waits=[a.wait for a in Customers]
    Mean_Wait=sum(Waits)/len(Waits)

    Total_Times=[a.wait+a.service_time for a in Customers]
    Mean_Time=sum(Total_Times)/len(Total_Times)

    Service_Times=[a.service_time for a in Customers]
    Mean_Service_Time=sum(Service_Times)/len(Service_Times)

    Utilisation=sum(Service_Times)/t
    return Mean_Wait, Mean_Time, Mean_Service_Time, Utilisation

@parallel
def myrandom(lmbda=1, mu=2, T=5):
    random.seed()
    return random.random()

if __name__ == '__main__':
    lmbda = 1
    mu = 2
    T = 10000
    trials = 50
    parameters = [(lmbda, mu, T, random.random()) for trials in range(trials)]
    r = mm1sim(parameters)

    f = open('outputofmm1.csv', 'w')
    csvwrtr = csv.writer(f)
    for result in r:
        csvwrtr.writerow(result[1])
    f.close()
