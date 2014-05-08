import StaticHeuristic
import TwoQueueVia3 as TwoQueueVia
import Simm
import csv
import random

@parallel
def func(n):
    while True :
        mu = [random.uniform(2,5),random.uniform(2,5)]
        c = [random.randint(2,4),random.randint(2,4)]
        skip = [random.uniform(0.5,0.8),random.uniform(0.5,0.8)]
        for e in range(1,50):

            lmbda = e
            print lmbda
            print mu
            print c
            print skip

            Object2 = TwoQueueVia.Queue(lmbda,mu,c,skip)
            ViaOut = Object2.VIA(0.1)

            Object1 = StaticHeuristic.n2approx(lmbda,mu,c,skip)
            HeuristicPolicy = Object1.calculate_D(20,20)
            Object3 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = HeuristicPolicy)
            HeuristicCost = Object3.VIA(0.1)[0]
            Object4 = Simm.RoutingSimm(lmbda,mu,c,skip,500,HeuristicPolicy,100,[0,0],Policy_type = 'Matrix')
            Object5 = Simm.RoutingSimm(lmbda,mu,c,skip,500,ViaOut[2],100,[0,0],Policy_type = 'Matrix')

            Object6 = StaticHeuristic.independant(lmbda,mu,c,skip)
            indepPolicy = Object6.calculate_D(20,20)
            Object7 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = indepPolicy)
            Object8 = Simm.RoutingSimm(lmbda,mu,c,skip,500,indepPolicy,100,[0,0],Policy_type = 'Matrix')
            indepCost = Object7.VIA(0.1)[0]

            outfile = open('./Static/MDP/Comparisons/out/LambdaComp(%s,%s,%s).csv' %(mu,c,skip),'ab')
            output = csv.writer(outfile)
            outrow = []
            outrow.append(lmbda)
            outrow.append(mu[0])
            outrow.append(mu[1])
            outrow.append(c[0])
            outrow.append(c[1])
            outrow.append(skip[0])
            outrow.append(skip[1])

            outrow.append(HeuristicCost)
            outrow.append(Object4[0])
            outrow.append(HeuristicPolicy.str())

            outrow.append(indepCost)
            outrow.append(Object8[0])
            outrow.append(indepPolicy.str())

            outrow.append(ViaOut[0])
            outrow.append(Object5[0])
            outrow.append(ViaOut[2].str())

            output.writerow(outrow)
            outfile.close()
list(func([1,2,3,4,5,6,7,8]))
