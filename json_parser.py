import json
import sys

with open(sys.argv[1]) as f:
	data = json.load(f)

nonodes = len(data['nodes'])
nolinks = len(data['links'])
print('number of nodes',nonodes)
print('number of links',nolinks)

origin = ''
connected = ''
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
	print('[' +str(origin)+','+str(connected)+']['+str(data['links'][x][2])+','+str(data['links'][x][4])+']')

