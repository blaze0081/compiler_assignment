from nltk.tree import *

# assign your output (generalied list of the syntax tree) to varaible text
f = open('tree.txt', 'r')

text = f.readlines()[0]
f.close()




text = text.replace("(", "")    #in the syntax tree, 'ob' will display in place of '('
text = text.replace(")", "")    #in the syntax tree, 'cb' will display in place of ')'
text = text.replace("[", "(")
text = text.replace("]", ")")


tree = Tree.fromstring(text)
tree.pretty_print(unicodelines=True, nodedist=10)   

