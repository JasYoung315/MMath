
class Queue: #A class for the queueing system
    #def __init__(self,lmbda,mu,C,beta,Policy = matrix([[0,0,2,2,2],[0,0,0,0,2],[1,1,1,2,2]])):
    def __init__(self,lmbda,mu,C,beta,Policy  = 7,bounds = [20,20]):
        self.lmbda = lmbda
        self.mu = mu
        self.beta = beta
        self.servers = C
        self.Policy = Policy

        self.StateValues = {}
        self.StateValues[0] = {}
        self.StateActions = {}
        self.StateActions[0] = {}
        self.states = []
        if self.Policy == 7:
            self.Selfish =  bounds
        else:
            self.Selfish = [self.Policy.nrows() + 1,self.Policy.ncols() + 1]
        self.VIAStates = []
        self.NoStates = (self.Selfish[0] + 1)*(self.Selfish[1] + 1)

        self.TranProbs = {}
        self.Plmbda = lmbda/(lmbda + sum([C[e]*mu[e] for e in range(2)]))
        self.Pmu1 = (mu[0]*C[0])/(lmbda + sum([C[e]*mu[e] for e in range(2)]))
        for e in range((self.Selfish[0] + 1)):
            for k in range((self.Selfish[1] + 1) ):
                self.states.append([e,k])

        for e in range((self.Selfish[0] +1 )):
            for k in range((self.Selfish[1] + 1) ):
                if e < self.servers[0] or k < self.servers[1]:
                    for j in range(4):
                        self.VIAStates.append([e,k,j])
                        self.StateValues[0]['%s' %([e,k,j])] = 0
                else:
                    for j in range(3):
                        self.VIAStates.append([e,k,j])
                        self.StateValues[0]['%s' %([e,k,j])] = 0

        self.A = [0,1,2]
        self.ADict = {}
        for e in self.states:
            if self.Policy == 7:
                if e[0] < self.Selfish[0] - 1 and e[1] < self.Selfish[1] - 1:
                    self.ADict['%s' %e] = [0,1,2]
                elif e[0] >= self.Selfish[0] - 1   and e[1] < self.Selfish[1] - 1  :
                    self.ADict['%s' %e] = [1,2]
                elif e[0] < self.Selfish[0] - 1 and e[1] >= self.Selfish[1] - 1 :
                    self.ADict['%s' %e] = [0,2]
                elif e[0] >= self.Selfish[0] - 1 and e[1] >= self.Selfish[1] - 1:
                    self.ADict['%s' %e] = [2]
            else:
                if e[0] < self.Selfish[0] - 2 and e[1] < self.Selfish[1] - 2:
                    self.ADict['%s' %e] = [self.Policy[e[0],e[1]]]
                elif e[0] >= self.Selfish[0] - 2 and e[1] < self.Selfish[1]  - 2:
                    self.ADict['%s' %e] = [1,2]
                elif e[0] < self.Selfish[0] - 2 and e[1] >= self.Selfish[1] - 2 :
                    self.ADict['%s' %e] = [0,2]
                elif e[0] >= self.Selfish[0] - 2 and e[1] >= self.Selfish[1] - 2:
                    self.ADict['%s' %e] = [2]

        self.findQ()
        self.findP()

    def findQ(self): #Transition rate matrix for the queue
        Q = MatrixSpace(QQ,len(self.states),len(self.states))
        rowdata = []

        for e in self.states:

            for i in self.states:
                if i[0] == e[0] + 1 and i[1] == e[1]:
                    rowdata.append(self.lmbda)


                elif i[0] == e[0]-1 and i[1] == e[1]+1:
                    if e[0]<= self.servers[0]:
                        rowdata.append(e[0]*self.mu[0])
                    else:
                        rowdata.append(self.servers[0]*self.mu[0])

                elif i[0] == e[0] and i[1] == e[1] - 1:
                    if e[1]<= self.servers[1]:
                        rowdata.append(e[1]*self.mu[1] )
                    else:
                        rowdata.append(self.servers[1]*self.mu[1])

                else:
                    rowdata.append(0)

        self.Q = Q(rowdata)
        rowsums = [sum(e) for e in self.Q]
        for i in range(self.NoStates):
            self.Q[i,i] = -rowsums[i]


    def findP(self): #Converts Q to P
        Diag = []

        for e in range(self.NoStates):

            Diag.append(abs(self.Q[e][e]))
        t = 1/max(Diag)
        self.P = self.Q*t + identity_matrix(self.Q.nrows())

        for e  in range(self.P.nrows()):
            self.TranProbs['%s' %self.states[e]] = {}

            for k in range(self.P.nrows()):
                if self.states[e][0] == 19:
                    print self.states[e],self.states[k],self.P[e][k]
                self.TranProbs['%s' %self.states[e]]['%s' %self.states[k]] = self.P[e][k]

    def Cost(self,state,action):


        if state[-1] == 0 :

            if action == 0:
                if state[0] < self.servers[0]:
                    return 1/self.mu[0]
                else :
                    return (state[0] + 1)/(self.servers[0]*self.mu[0])

            elif action == 1:
                if state[1] < self.servers[1]:
                    return 1/self.mu[1] + self.beta[0]
                else :
                    return (state[1] + 1)/(self.servers[1]*self.mu[1]) + self.beta[0]

            elif action == 2:
                return sum(self.beta)

        if state[-1] == 1 :
            if state[1] < self.servers[1] and not state[1] == 0:
                return 1/self.mu[1]
            elif state[1] == 0:
                return 0
            else :
                return (state[1])/(self.servers[1]*self.mu[1])

        if state[-1] == 2 or state[-1] == 3:
            return 0


    def Transition(self,state,T):
        if state[-1] == 0:
            objective = []

            for a in self.ADict['%s' %([state[0],state[1]])]:

                Value = self.Cost(state,a)

                NewState = list(state)
                if not a == 2:
                    NewState[a] += 1

                for e in self.VIAStates:

                    eventtype =10
                    if e[0] == NewState[0] and e[1] == NewState[1] and not e[-1] == 0:
                        if NewState[0] < self.servers[0] or NewState[1] < self.servers[1]:
                            eventtype = 3
                        else:
                            eventtype = 1

                    elif e[0] == min(NewState[0] + 1,self.Selfish[0]) and e[1] == NewState[1] :
                        eventtype = 0
                    elif e[0] == NewState[0] - 1 and e[1] == min(NewState[1] + 1,self.Selfish[1]):
                        eventtype = 1
                    elif e[0] == NewState[0]  and e[1] == NewState[1] - 1 :
                        eventtype = 2

                    if eventtype == e[-1] and not self.TranProbs['%s' %([NewState[0],NewState[1]])]['%s' %([e[0],e[1]]) ] == 0:
                        #print state,a,NewState,e,self.TranProbs['%s' %([NewState[0],NewState[1]])]['%s' %([e[0],e[1]]) ]
                        if eventtype == 0 :
                            Value += self.TranProbs['%s' %([NewState[0],NewState[1]])]['%s' %([e[0],e[1]]) ]*self.StateValues[ T - 1 ]['%s' %([max(e[0] - 1,0)] + e[1:])]
                        else:
                            Value += self.TranProbs['%s' %([NewState[0],NewState[1]])]['%s' %([e[0],e[1]]) ]*self.StateValues[T - 1]['%s' %([min([e[0],self.Selfish[0]]),min([e[1],self.Selfish[1]]),eventtype])]

                objective.append(Value)
            #print state, objective
            return min(objective),self.ADict['%s' %([state[0],state[1]])][objective.index(min(objective))]

        else:
            Value = self.Cost(state,0)

            for e in self.VIAStates:
                eventtype = 10
                if e[0] == state[0] and e[1] == state[1] and not e[-1] == 0:
                    if state[0] < self.servers[0] or state[1] <self.servers[1]:
                        eventtype = 3
                    else:
                        eventtype = 1
                elif e[0] == state[0] + 1 and e[1] == state[1] :
                    eventtype = 0
                elif e[0] == state[0] - 1 and e[1] == min(state[1] + 1,self.Selfish[1]):
                    eventtype = 1
                elif e[0] == state[0]  and e[1] == state[1] - 1 :
                    eventtype = 2

                if eventtype == e[-1] and not self.TranProbs['%s' %([state[0],state[1]])]['%s' %([e[0],e[1]]) ] == 0:
                    #print state,e,self.TranProbs['%s' %([state[0],state[1]])]['%s' %([e[0],e[1]]) ]
                    if eventtype == 0 :
                        Value += self.TranProbs['%s' %([state[0],state[1]])]['%s' %([e[0],e[1]]) ]*self.StateValues[ T - 1 ]['%s' %([max(e[0] - 1,0)] + e[1:])]

                    else:
                        Value += self.TranProbs['%s' %([state[0],state[1]])]['%s' %([e[0],e[1]]) ]*self.StateValues[T - 1]['%s' %([min([e[0],self.Selfish[0]]),min([e[1],self.Selfish[1]]),eventtype])]

            return Value,3


    def VIA(self,epsilon = 0.1):

        T = 1
        end = False

        while not end:

            self.StateValues[T] = {}
            self.StateActions[T] = {}

            for s in self.VIAStates:
                Opt = self.Transition(s,T)
                self.StateValues[T]['%s' %(s)] = Opt[0]
                self.StateActions[T]['%s' %(s)] = Opt[1]

            print '---- T = %s ----' %T
            RefVal = self.StateValues[T]['%s' %([0,0,2])]

            for e in self.StateValues[T]:
                self.StateValues[T][e] -= RefVal

            epsilonlist = [abs(self.StateValues[T][e] - self.StateValues[T - 1][e]) for e in self.StateValues[T] ]

            end = True
            print  'LongRunAve =  %.02f' %self.StateValues[T]['%s'%([0,0,0])]
            for e in epsilonlist:
                if e > epsilon:
                    end  = False
            if not end:
                T +=1
        M = matrix(self.Selfish[0]  + 1)
        if self.Policy == 7:
            for e in self.VIAStates:

                if e[-1] == 0 and e[0] <= self.Selfish[0] and e[1] <= self.Selfish[1]:
                    M[e[0],e[1]] = self.StateActions[T]['%s' %e]
        return self.Plmbda*self.StateValues[T]['%s'%([0,0,0])],self.StateActions[T],M
'''
lmbda = 10
mu = [5,4]
c = [5,5]
beta = [1,1]
a = Queue(lmbda,mu,c,beta)
print a.VIA(0.1)[2]
'''
