with open("input.txt","r") as fd:
    lines = fd.readlines()
    lines = [int(x.strip())*811589153 for x in lines]
    bop = set()
    for i in lines:
        while i in bop:
            i+=1000000000 if i>0 else -10000

        bop.add(i)
        print(i)


