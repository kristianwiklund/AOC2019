from copy import deepcopy

def tjonk(s):
    t = s[0:3]
    r = s[4:]

    if t=="   ":
        t=None

    return (t,r)

torn = dict()
for i in range(1,10):
    torn[i]=list()

with open("input.torn","r") as fd:

    lines = [x.rstrip() for x in fd.readlines()]

    for line in lines:
        i = 1
        
        while line:
            (t,line)=tjonk(line)
            if t:
                torn[i].append(t)

            i+=1

for i in range(1,10):
    torn[i].reverse()

tb = deepcopy(torn)
    
def move(torn,n,f,t):
    while n:
        b = torn[f].pop()
        torn[t].append(b)
        n-=1
    return torn


def move9001(torn,n,f,t):
    l = list()
    while n:
        b = torn[f].pop()
        l.append(b)
        n-=1
    l.reverse()
    torn[t] = torn[t]+l
    return torn

with open("input.code","r") as fd:

    lines = [x.strip() for x in fd.readlines()]

    for line in lines:
        line = line.split(" ")
        n = int(line[1])
        f = int(line[3])
        t = int(line[5])

        torn = move(torn,n,f,t)
        tb = move9001(tb,n,f,t)
        
print("Part 1: ",end="")

for i in range(1,10):
    torn[i].reverse()
    if len(torn[i]):
        print(torn[i][0].replace("[","").replace("]",""),end="")
    else:
        print("...",end="")
        
print("")

print("Part 2: ",end="")

for i in range(1,10):
    tb[i].reverse()
    if len(tb[i]):
        print(tb[i][0].replace("[","").replace("]",""),end="")
    else:
        print("...",end="")
        
print("")

