#!/usr/bin/python

import urllib2, sys, getopt, re

def getlinks(a):
    shorturl=re.search('\.?(\w*\.\w*)', a)
    masterlist=[]
    try:
        b = urllib2.urlopen(a)
    except:
        print "Unable to open URL: %s" % a
        return masterlist
    for line in b:
        list1 = re.findall('href=[\'"]?([^\'" >]+)', line)
        for item in list1:
            if re.match('^\/', item):
                masterlist.append(a+item)
            if shorturl.group(1) in item:
                masterlist.append(item)
    return masterlist


def listqu(masterlist, shortlist):
    x=len(masterlist)
    a = masterlist[1]

    ncount=0

    while ncount < len(shortlist):

        if shortlist[ncount] in masterlist:
            shortlist.pop(ncount)
            ncount = ncount - 1

        ncount = ncount + 1
    return shortlist

###################

testlist = set(sys.argv[1])
print testlist

###################

masterlist = [sys.argv[1]]
masterlist = masterlist + getlinks(sys.argv[1])
x = 0
while x < len(masterlist):
    shortlist = getlinks(masterlist[x])
    masterlist = masterlist + listqu(masterlist, shortlist)
    if x==50:
        break
    x=x+1
    print x
for item in masterlist:
    print item
