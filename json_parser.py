import json
import pickle
import sys
import getopt
from os import listdir
from os.path import isfile, join
import random

datadir = './nodes/node_data/'
crimfiles = [f for f in listdir(datadir) if isfile(join(datadir, f))]


while True:
	crmid = random.randint(0,10000)
	if not crmid in crimfiles :
		break


argv = sys.argv[1:]
try:
    opts, args = getopt.getopt(argv, 'hnf:oi:m:', ['help','nonodes', 'inputjson=','printoutput','crimeid=','personname='])

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
	if k == '-i':
		crmid = int(v)
	if k == '-m':
		name = v
	if k == '-h':
		print('please specify -m <person name> -f <location file> -i <crimeid> these are the most compulsory and important params')
		sys.exit()

with open(infile) as f:
	data = json.load(f)

nonodes = len(data['nodes'])
nolinks = len(data['links'])

if disp_node:
	print(nonodes)
	print(nolinks)

origin = ''
connected = ''
nodesconnected = list()
for x in range(0,nolinks):
	idcur = data['links'][x][1]
	idtarg = data['links'][x][3]
	for y in range(0,nonodes):
		if data['nodes'][y]['id'] == idcur :
			#print("origin:",data['nodes'][y]['type'])
			origin = data['nodes'][y]['type']
		if data['nodes'][y]['id'] == idtarg :
			#print("target:",data['nodes'][y]['type'])
			connected = data['nodes'][y]['type']

	nodesconnected.append(origin)
	nodesconnected.append(connected)
	if shownodes : print('[' +str(origin)+','+str(connected)+']['+str(data['links'][x][2])+','+str(data['links'][x][4])+']')


crmout = {'crmid':crmid,'name':name,'nodesall':nodesconnected,'nonodes':nonodes,'nolinks':nolinks}
print(crmout)

