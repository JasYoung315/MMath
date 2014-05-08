# This file was *autogenerated* from the file /home/c1012211/Static/MDP/Comparisons/Timings3.sage.
from sage.all_cmdline import *   # import sage library
import StaticHeuristic
import TwoQueueVia3 as TwoQueueVia
import Simm
import csv
import random
import time

@parallel
def func(n):
    while True :
        for e in range(Integer(5),Integer(20)):
            lmbda = random.uniform(Integer(20),Integer(100))
            mu = [random.uniform(Integer(2),Integer(10)),random.uniform(Integer(2),Integer(10))]
            c = [random.randint(Integer(2),Integer(7)),random.randint(Integer(2),Integer(7))]
            skip = [random.uniform(RealNumber('0.5'),Integer(5)),random.uniform(RealNumber('0.5'),Integer(5))]

            print lmbda
            print mu
            print c
            print skip

            start = time.time()
            Object2 = TwoQueueVia.Queue(lmbda,mu,c,skip,bounds = [Integer(20),Integer(20)])
            ViaOut = Object2.VIA(RealNumber('0.1'))
            viatime = time.time() - start

            Object5 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),ViaOut[Integer(2)],Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')

            start = time.time()
            Object6 = StaticHeuristic.independant(lmbda,mu,c,skip)
            indepPolicy = Object6.calculate_D(Integer(20),Integer(20))
            indeptime = time.time() - start

            Object7 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = indepPolicy)
            Object8 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),indepPolicy,Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')
            indepCost = Object7.VIA(RealNumber('0.1'))[Integer(0)]

            start = time.time()
            Object9 = StaticHeuristic.n2Simm(lmbda,mu,c,skip)
            SimmN2Policy = Object9.calculate_D(Integer(20),Integer(20))
            SimmN2time = time.time() - start

            Object10 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = SimmN2Policy)

            SimmN2Cost = Object10.VIA(RealNumber('0.1'))[Integer(0)]
            Object11 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),SimmN2Policy,Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')

            start = time.time()
            Object12 = StaticHeuristic.simulation(lmbda,mu,c,skip)
            SimmPolicy = Object12.calculate_D(Integer(20),Integer(20))
            Simmtime = time.time() - start

            Object13 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = SimmPolicy)
            SimmCost = Object13.VIA(RealNumber('0.1'))[Integer(0)]
            Object14 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),SimmPolicy,Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')
            start = time.time()

            outfile = open('./Static/MDP/Comparisons/out/Timings4.csv','ab')
            output = csv.writer(outfile)
            outrow = []
            outrow.append(e)
            outrow.append(lmbda)
            outrow.append(mu[Integer(0)])
            outrow.append(mu[Integer(1)])
            outrow.append(c[Integer(0)])
            outrow.append(c[Integer(1)])
            outrow.append(skip[Integer(0)])
            outrow.append(skip[Integer(1)])

            outrow.append(indepCost)
            outrow.append(Object8[Integer(0)])
            outrow.append(indeptime)
            outrow.append(indepPolicy.str())

            outrow.append(ViaOut[Integer(0)])
            outrow.append(Object5[Integer(0)])
            outrow.append(viatime)
            outrow.append(ViaOut[Integer(2)].str())

            outrow.append(SimmCost)
            outrow.append(Simmtime)
            outrow.append(Object14[Integer(0)])
            outrow.append(SimmPolicy.str())

            outrow.append(SimmN2Cost)
            outrow.append(Object11[Integer(0)])
            outrow.append(SimmN2time)
            outrow.append(SimmN2Policy.str())

            output.writerow(outrow)
            outfile.close()
list(func([Integer(1),Integer(2),Integer(3),Integer(4),Integer(5),Integer(6),Integer(7)]))
#func(7)
