# various utility functions that could be reusable

# usage
# import sys
# sys.path.append("../..")
# from utilities import *

# reads a block of lines separated with empty lines from a file
def readblock(fd):
    elf = list()
    x = fd.readline().strip()
    
    while x:
        if x=="":
            return elf
        elf.append(int(x))
        
        x = fd.readline().strip()

    return elf

# reads a file to an array
def readarray(fn, split=" ", convert=lambda x:x):

    arr = []
    
    with open(fn, "r") as fd:
        lines = fd.readlines()

        for line in lines:
            line = line.strip()

            la = [convert(x) for x in line.split(split)]
            arr.append(la)

        return arr

    return None

# factorization
from functools import reduce

def factors(n):    
    return set(reduce(list.__add__, 
                ([i, n//i] for i in range(1, int(n**0.5) + 1) if n % i == 0)))


# Returns the longest repeating non-overlapping
# substring in str
def lrs(str):
 
    n = len(str)
    LCSRe = [[0 for x in range(n + 1)]
                for y in range(n + 1)]
 
    res = "" # To store result
    res_length = 0 # To store length of result
 
    # building table in bottom-up manner
    index = 0
    for i in range(1, n + 1):
        for j in range(i + 1, n + 1):
             
            # (j-i) > LCSRe[i-1][j-1] to remove
            # overlapping
            if (str[i - 1] == str[j - 1] and
                LCSRe[i - 1][j - 1] < (j - i)):
                LCSRe[i][j] = LCSRe[i - 1][j - 1] + 1
 
                # updating maximum length of the
                # substring and updating the finishing
                # index of the suffix
                if (LCSRe[i][j] > res_length):
                    res_length = LCSRe[i][j]
                    index = max(i, index)
                 
            else:
                LCSRe[i][j] = 0
 
    # If we have non-empty result, then insert
    # all characters from first character to
    # last character of string
    if (res_length > 0):
        for i in range(index - res_length + 1,
                                    index + 1):
            res = res + str[i - 1]
 
    return res
 
