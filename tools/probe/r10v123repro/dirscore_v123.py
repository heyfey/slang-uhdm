import sys, collections
def ms(p):
    try: return collections.Counter(open(p).read().splitlines())
    except FileNotFoundError: return collections.Counter()
g,o,q = ms(sys.argv[1]), ms(sys.argv[2]), ms(sys.argv[3])
match_o = sum((g & o).values()); match_q = sum((g & q).values())
# lines present in ours-patched but neither in golden nor in ours-pristine
new_wrong = q - o - g
lost_match = (g & o) - (g & q)     # golden-matching cells we USED to have and lost
print("GOLD=%d OURS_p=%d OURS_q=%d  MATCH %d->%d  NEW_NONGOLD=%d LOST_GOLDMATCH=%d"
      % (sum(g.values()), sum(o.values()), sum(q.values()), match_o, match_q,
         sum(new_wrong.values()), sum(lost_match.values())))
for k,v in sorted(new_wrong.items()): print("   NEW_NONGOLD x%d %s" % (v,k))
for k,v in sorted(lost_match.items()): print("   LOST        x%d %s" % (v,k))
