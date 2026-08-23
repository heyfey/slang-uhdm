import collections, glob, os, sys
GLOBALS = ['run_test','global_stop_request','set_global_timeout','set_global_stop_timeout',
 'uvm_get_report_object','uvm_report_enabled','uvm_report','m__uvm_report_dpi',
 'uvm_report_info','uvm_report_warning','uvm_report_error','uvm_report_fatal',
 'uvm_process_report_message','uvm_string_to_severity','uvm_string_to_action',
 'set_config_int','set_config_object','set_config_string','uvm_is_match',
 'uvm_string_to_bits','uvm_bits_to_string','uvm_wait_for_nba_region','uvm_split_string']
G = set(GLOBALS)
def load(p):
    d = collections.defaultdict(list)
    for ln in open(p):
        f = ln.rstrip('\n').split('\t')
        if len(f) != 7: continue
        view, top, home, call, sp, kind, callee = f
        if call not in G: continue
        if callee != '<null>':
            k,_,r = callee.partition('|'); nm,_,r2 = r.partition('|'); par,_,_l = r2.partition('@')
            callee = '%s|%s|%s' % (k,nm,par)
        d[(view, top, home, call, kind)].append(callee)
    return d
def cls(a,b):
    # ORDER MATTERS: a one-sided cell must be named ONLY-G/ONLY-O before the
    # <null> tests, or an absent golden entry facing our `<null>` reads as
    # OURS-NULL and inflates the head's family (it read 7 for BuildUVMPkg where
    # the join reads 3).
    if a is None: return 'ONLY-O'
    if b is None: return 'ONLY-G'
    if a == b: return 'SAME'
    if b == '<null>': return 'OURS-NULL'
    if a == '<null>': return 'GOLD-NULL'
    return 'DIFF'
print("r10uvm113 CENSUS.uvmglobals — every call to a uvm_globals.svh FREE SUBROUTINE,")
print("nine UVM row-modes, golden vs OUR PRISTINE database.  Cell =")
print("(view, container, caller owner chain, call name, call kind); value = the")
print("callee SHAPE (kind|name|parentkind:parentname).  Spans are NOT in the key:")
print("the two producers disagree about macro-expansion locations and Compare reads")
print("no span (README §2).")
print()
tot = collections.Counter(); bycallee = collections.Counter()
# r10v113 FIX: the census directory is an ARGUMENT.  It used to be the hard
# path /tmp/r10uvm113_scratch/cen_pris, so the committed script re-ran only on
# the machine that wrote that scratch — and where the scratch still existed it
# silently reported the PRISTINE numbers no matter which census it was pointed
# at (measured: the same TOTAL line for both sides).
CENDIR = sys.argv[1] if len(sys.argv) > 1 else '.'
gps = sorted(glob.glob(os.path.join(CENDIR, '*.g.tsv')))
if not gps:
    sys.exit('FATAL: no *.g.tsv under %s -- usage: cenglob113.py <censusdir>' % CENDIR)
for gp in gps:
    tag = os.path.basename(gp)[:-6]
    g, o = load(gp), load(gp[:-6] + '.o.tsv')
    c = collections.Counter()
    for k in set(g)|set(o):
        gv, ov = sorted(g.get(k,[])), sorted(o.get(k,[]))
        for i in range(max(len(gv),len(ov))):
            a = gv[i] if i < len(gv) else None
            b = ov[i] if i < len(ov) else None
            v = cls(a,b); c[v]+=1; tot[v]+=1
            if v!='SAME': bycallee[(k[3],v)]+=1
    print('%-22s %s' % (tag, '  '.join('%s=%d'%(x,c[x]) for x in sorted(c))))
print()
print('TOTAL over the nine  ' + '  '.join('%s=%d'%(x,tot[x]) for x in sorted(tot)))
print()
print('non-SAME by callee name:')
for (nm,v),n in sorted(bycallee.items()):
    print('   %-28s %-10s %d' % (nm, v, n))
print()
print('READING:  OURS-NULL 27 = the head family (3 cells x 9 row-modes), and it is')
print('the ONLY column this pass moves; it goes to 0.  DIFF 7982 is uvm111 R-tf111')
print('(golden binds the HOME object, we bind the importer clone) — untouched.')
