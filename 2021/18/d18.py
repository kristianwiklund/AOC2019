#!/usr/bin/python3

import re
import sys


level="\[[^\[\]]*"
fish="\[[0-9],[0-9]\]"
number="[0-9]"

def whot(s):
    l=0
    c=0
    for i in s:
        c+=1
        if i=="[":
            l+=1
            if l==5:
                match = re.search(fish,s[c-1:])
                (start,end)=match.span()
                c = c + start
                return c
        if i=="]":
            l-=1

    return None

def explode(s):
    restr = level+level+level+level+fish

    where = whot(s)

    if where:
        start = where
        end = where+3
        (l,r)=s[where:where+3].split(",")
        l = int(l)
        r = int(r)
        
        # find the first number to the right of the hit
        match = re.search(number,s[where+3:])
        if match:
            (startr,endr)=match.span()
            value=int(s[end+startr:][0])

            s = s[:end+startr]+str(value+r)+s[end+startr+1:]

        # explode the hit

        s = s[:where-1]+"0"+s[where+4:]

        # find the first number to the left of the hit

        w = s[:where-1][::-1]

        match = re.search(number,w)
        if match:

            (startr,endr)=match.span()
            value=int(w[startr:][0])
            w = w[:startr]+str(value+l)+w[startr+1:]

            w=w[::-1]

            s = w + s[where-1:]



    return s

try:
    s1="[[[[[9,8],1],2],3],4]"
    assert (explode(s1) == "[[[[0,9],2],3],4]")
except:
    print (explode(s1))
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
