import json
import pickle
import sys
import getopt
from os import listdir
from os.path import isfile, join
import random
import pandas as pd


def checkinexclusion(nodename):
    with open('./nodes/exclusion.nodes', 'r') as nodelines:
        for x in nodelines.readlines():
            # print(nodename)
            if x.strip() == nodename:
                return
    return nodename


datadir = './nodes/node_data/'
crimfiles = [f for f in listdir(datadir) if isfile(join(datadir, f))]


while True:
    crmid = random.randint(0, 10000)
    if not crmid in crimfiles:
        break


argv = sys.argv[1:]
try:
    opts, args = getopt.getopt(argv, 'hnf:om:', ['help', 'nonodes', 'inputjson=', 'printoutput', 'crimeid=', 'personname='])

except getopt.GetoptError:
    print('Something went wrong!')
    sys.exit(2)

disp_node = False
shownodes = False
infile = ''
name = ''
for k, v in opts:
    if k == '-n':
        disp_node = True
    if k == '-f':
        infile = v
    if k == '-o':
        shownodes = True
    if k == '-m':
        name = v
    if k == '-h':
        print('please specify -f <location file> -m <name of guys> these are the most compulsory and important params')
        sys.exit()

with open(infile) as f:
    data = json.load(f)

nonodes = len(data['nodes'])
nolinks = len(data['links'])

if disp_node:
    print(nonodes)
    print(nolinks)

for x in range(0, nonodes):
    if data['nodes'][x]['type'] == "Crime/CrimeID":
        crmid = data['nodes'][x]['properties']['value']

origin = ''
connected = ''
nodesconnected = list()
for x in range(0, nolinks):
    idcur = data['links'][x][1]
    idtarg = data['links'][x][3]
    for y in range(0, nonodes):
        if data['nodes'][y]['id'] == idcur:
            origin = checkinexclusion(data['nodes'][y]['type'])
        if data['nodes'][y]['id'] == idtarg:
            connected = checkinexclusion(data['nodes'][y]['type'])

    nodesconnected.append(origin)
    nodesconnected.append(connected)
    #if shownodes : print('[' +str(origin)+','+str(connected)+']['+str(data['links'][x][2])+','+str(data['links'][x][4])+']')

nodesconnected = list(set(list(filter(None, nodesconnected))))
crmout = {'crmid': crmid, 'name': name, 'nodesall': nodesconnected, 'nonodes': len(nodesconnected), 'nolinks': nolinks}
print(crmout)


###########################################
nodesconnected = ['Mood/Alcoholic', 'Activity/Driving']
data = {}
n = 1
data['CrimeID'] = n
for i in nodesconnected:
    val = i.split("/")
    if val[0] in data.keys():
        data[val[0]].append([val[1]])
    else:
        data[val[0]] = [val[1]]
n += 1
print(data)
df = pd.DataFrame.from_dict(data, orient='columns')
print(df.head())
df.to_csv('temp_data.csv', header=True, index=False)
##########################################
