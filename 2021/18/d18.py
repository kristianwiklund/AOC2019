#!/usr/bin/python3

import re
import sys

from colorama import Fore
from colorama import Style



level="\[[^\[\]]*"
fish="\[[0-9][0-9]*,[0-9][0-9]*\]"
number="[0-9]"

cols= [Fore.BLACK, Fore.RED, Fore.GREEN, Fore.YELLOW, Fore.BLUE, Fore.MAGENTA]

def whot(s):
    l=0
    c=0
    for i in s:
        c+=1
        if i=="[":
            l+=1

            if l==5:
                try:
                    #print(Fore.WHITE+s[c-1:]+Style.RESET_ALL,"<--whot")
                    match = re.search(fish,s[c-1:])
                    (start,end)=match.span()
                    c = c + start
                    return c
                except:
                    print("wot fail",c, s[:c-1]+"^"+s[c-1:],s)
                    sys.exit()
            #print(cols[l%6]+i,end="")
        elif i=="]":
            l-=1
            #print(cols[l%6]+i,end="")
        else:
            pass
            #print(i,end="")
    #print(Style.RESET_ALL)
    return None

def explode(s):
    restr = level+level+level+level+fish

    where = whot(s)

    if where:
        start = where

        for t in range(0,6):
            if s[t+where]=="]":
                break
        end = start+t
        
        (l,r)=s[where:where+t].split(",")
        #print ("fisk",s[where:where+t])
        l = int(l)
        r = int(r)
        
        # find the first fish to the right of the hit
        match = re.search(number,s[end:])
        if match:
            (startr,endr)=match.span()
            #print (s[end+startr:],"<--")
            #            value=int(s[end+startr:][0])

            if s[end+startr+1] not in "[],":
                sdf=2
            else:
                sdf=1
                #            print(s[end+startr:end+startr+sdf])
            value=int(s[end+startr:end+startr+sdf])

            s = s[:end+startr]+str(value+r)+s[end+startr+sdf:]

        # explode the hit

        s = s[:where-1]+"0"+s[end+1:]

        # find the first number to the left of the hit

        w = s[:where-1][::-1]

        match = re.search(number,w)
        if match:

            (startr,endr)=match.span()
            value=int(w[startr:][0])

            w = w[:startr]+(str(value+l)[::-1])+w[startr+1:]
        
            w=w[::-1]
            
            s = w + s[where-1:]

    return s

def add(x,y):
    return "["+x+","+y+"]"

def split(s):

    match = re.search(number+number,s)
    if not match:
        return s

    (start,end)=match.span()
    #print(start,end)
    v = int(s[start:end])

    return s[:start]+"["+str(v//2)+","+str(v-v//2)+"]"+s[end:]

# reduce
# run explodes, until explodes cannot be run more

def red(s):


    while True:
        os = s
        vs = s
        s = explode(s)
        if s!=os:
            continue

        os = s
        s = split(s)
        if s!=os:
            continue
        
        
        if s==vs:
            break
    return s



# ------------- test cases ---------------

# explode

try:
    s1="[[[[[9,8],1],2],3],4]"
    assert (explode(s1) == "[[[[0,9],2],3],4]")
except:
    print (explode(s1),"<--fel")
    print ("[[[[0,9],2],3],4]")
    sys.exit()
    
try:
    s2="[7,[6,[5,[4,[3,2]]]]]"
    assert(explode(s2) == "[7,[6,[5,[7,0]]]]")
except:
    print (explode(s2))
    print ( "[7,[6,[5,[7,0]]]]")
    sys.exit()
    
try:
    s3="[[6,[5,[4,[3,2]]]],1]"
    assert (explode(s3) == "[[6,[5,[7,0]]],3]")
except:
    print(explode(s3))
    print("[[6,[5,[7,0]]],3]")
    sys.exit()
    
s4="[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]"
assert (explode(s4) == "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")

try:
    s5="[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"
    assert(explode(s5) == "[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
except:
    print (s5)
    print (explode(s5))
    print("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
    sys.exit()

# add
    
assert(add("[1,2]","[[3,4],5]")=="[[1,2],[[3,4],5]]")
assert(add("[[[[4,3],4],4],[7,[[8,4],9]]]","[1,1]")=="[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")
assert(add(add(add("[1,1]","[2,2]"),"[3,3]"),"[4,4]")=="[[[[1,1],[2,2]],[3,3]],[4,4]]")

# split

assert(split("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")=="[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")
assert(split("[[[[0,7],4],[15,[0,13]]],[1,1]]")=="[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")

s = add("[[[[4,3],4],4],[7,[[8,4],9]]]","[1,1]")
assert (s=="[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")
s = explode(s)
assert (s=="[[[[0,7],4],[7,[[8,4],9]]],[1,1]]")
s = explode(s)
try:
    assert (s=="[[[[0,7],4],[15,[0,13]]],[1,1]]")
except:
    print(s)
    sys.exit()
s = split(s)
s = split(s)
s = explode(s)
assert (s == "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")

# ------------


try:
    assert (red("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]") == "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
except:
    print(red("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"),"<--")
    print( "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
    sys.exit()
    
s = add(add(add(add("[1,1]","[2,2]"),"[3,3]"),"[4,4]"),"[5,5]")
assert (red(s) == "[[[[3,0],[5,3]],[4,4]],[5,5]]")

s = add(s,"[6,6]")
assert (red(s) == "[[[[5,0],[7,4]],[5,5]],[6,6]]")

# ---------------

# double numbers...

assert (explode("[[[[[14,8],1],2],3],4]")=="[[[[0,9],2],3],4]")

# big test case

def ass(s,wha):
    try:
        assert(s==wha)
    except:
        print (s,"<--fail")
        print(wha)
        sys.exit()


        

s= add("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]","[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]")
s = red(s)

ass (s,"[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]")

# ----

s=None
for l in sys.stdin:
    l=l.strip()

    if s is None:
        s = l
    else:
        s = add(s,l)
        s = red(s)

print(s)
