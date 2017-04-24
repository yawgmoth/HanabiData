import os
import sys

games = {}
participants = {}

cleanup = False

variables = {
"bgg": ["new", "dabbling", "intermediate", "expert"],
"exp": ["new", "dabbling", "intermediate", "expert"],
"recent": ["never", "long", "medium", "recent"],
"score": ["never", "few", "sometimes", "often"],
"skill": ["vbad", "bad", "ok", "good", "vgood"],
"like": ["vhate", "hate", "neutral", "like", "vlike"]
}

def map_value(variable, value):
    if variable in variables:
        try:
            return str(variables[variable].index(value) + 1)
        except Exception:
            import traceback
            traceback.print_exc()
    return value
    
ddgids = []
def parse_survey(fname):
    id = fname[-20:-4]
    if id not in participants:
        participants[id] = {}
    f = open(fname)
    for l in f:
        try:
            name,val = l.split()
            participants[id][name] = map_value(name, val)
        except Exception:
            import traceback
            traceback.print_exc()
    f.close()
    

    
    
def parse_game(fname):
    id = fname[-20:-4]
    games[id] = {}
    
    f = open(fname)
    games[id]["time"] = os.stat(fname).st_mtime
    for l in f:
        if l.startswith("Old GID:"):
            items = l.strip().split()
            games[id]["pred"] = items[-1]
        elif l.startswith("Treatment:"):
            items = l.strip().split()
            games[id]["ai"] = items[-2].strip("'(,")
            games[id]["deck"] = items[-1].strip(")")
        elif l.startswith("Score"):
            games[id]["score"] = l.strip().split()[-1]
    f.close()
    if not "score" in games[id] and cleanup:
        os.remove(fname)
        del games[id]
            

for f in os.listdir(sys.argv[1]):
    if f.startswith("survey"):
        parse_survey(os.path.join(sys.argv[1], f))
    elif f.startswith("game"):
        parse_game(os.path.join(sys.argv[1], f))
        

   
scores = {"full": [], "intentional": [], "outer": []}
for i in xrange(5):
    scores["full" + str(i+1)] = []
    scores["intentional" + str(i+1)] = []
    scores["outer" + str(i+1)] = []
    
publish = 0

def find_id(g):
    if "pred" in games[g]:
        return find_id(games[g]["pred"])
    return g

f = file("games.csv", "w")
print >> f, "id, ai, deck, score, time, first"

for g in games:
    if "score" in games[g]:
        id = find_id(g)
        if cleanup and (id not in participants or "publish" not in participants[id] or participants[id]["publish"] != "yes"):
            print "remove", os.path.join(sys.argv[1], "game%s.log"%g)
            os.remove(os.path.join(sys.argv[1], "game%s.log"%g))
            continue
        if int(games[g]["score"]) > 0:
            scores[games[g]["ai"]].append(int(games[g]["score"]))
        
        print >>f, id + ",", games[g]["ai"] + ",", games[g]["deck"] + ",", games[g]["score"] + ",", str(games[g]["time"]) + ",", "yes" if id == g else "no"
f.close()

f = file("participants.csv", "w")
print >>f, "id,ai,deck,score,age,boardgameexp,gamer,hanabiexp,recent,maxscore,intention,skill,like,publish"



for p in participants:
    if p in games and "score" in games[p]:
        if cleanup and ("publish" not in participants[p] or participants[p]["publish"] != "yes"):
            print "remove", os.path.join(sys.argv[1], "survey%s.log"%p)
            os.remove(os.path.join(sys.argv[1], "survey%s.log"%p))
            continue
        
        scores[games[p]["ai"] + games[p]["deck"]].append(int(games[p]["score"]))
        
        
        print >>f, p + ",",
        print >>f, games[p]["ai"] + ",",
        print >>f, games[p]["deck"] + ",",
        print >>f, games[p]["score"] + ",",
        
        for item in ["age", "bgg", "gamer", "exp", "recent", "score", "intention", "skill", "like"]:
            if item in participants[p]:
                print >>f, participants[p][item] +",",
            else:
                print >>f, ",",
        if "publish" in participants[p]:
            if participants[p]["publish"] == "yes":
                publish += 1
            print >>f, participants[p]["publish"],
        print >>f
    else:
        if cleanup:
            print "remove", os.path.join(sys.argv[1], "survey%s.log"%p)
            os.remove(os.path.join(sys.argv[1], "survey%s.log"%p))
        else:
            print p, "did not finish their game"
f.close()



import numpy
for key in scores:
    if key in ["full", "intentional", "outer"]:
        print "average of", key, "is", numpy.mean(scores[key])
        print "stddev of", key, "is", numpy.std(scores[key], ddof=1)
        print "range of", key, "is", numpy.min(scores[key]), "to", numpy.max(scores[key])
        
print "public", publish
