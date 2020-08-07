import pandas as pd
import sqlite3
import sys
import pandas as pd 
from io import StringIO 
from sklearn.svm import SVC


con = sqlite3.connect("./nodes/node_data/node_reg.db")
df = pd.read_sql_query("SELECT * from nodes", con)

X = df.drop(['name','nonodes','nolinks','crimeid'], axis=1)
y = df['crimeid']

txt = sys.argv[1]
inpdb = StringIO(txt.replace('|','\n'))
df2 = pd.read_csv(inpdb, sep =";") 
X_input = df2.drop(['name','nonodes','nolinks','crimeid'],axis=1)

svclassifier = SVC(kernel='poly')
svclassifier.fit(X,y)

y_pred = svclassifier.predict(X_input)
print(y_pred[0])
print(svclassifier.decision_function(X_input)[0][0])