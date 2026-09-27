import sys, re
for line in open(sys.argv[1]):
    line=line.strip()
    m = re.match(r'(\S+) pris:(\S+) law:(\S+)', line)
    if not m: print('??', line); continue
    rel, p, l = m.groups()
    def parse(s):
        d = {}
        if 'FAIL' in s: return {'fail': s}
        for kv in s.split(','):
            if '=' in kv: k,v = kv.split('=',1); d[k]=v
            elif kv: d.setdefault('verdict', kv)
        return d
    P, L = parse(p), parse(l)
    if 'fail' in P or 'fail' in L:
        print('FAIL', rel, p[:60], l[:60]); continue
    if P.get('md5') == L.get('md5'):
        cls = 'SAME'
    else:
        pc, lc = P['cmp'].split('/')[0], L['cmp'].split('/')[0]
        if pc == '0' and lc != '0': cls = 'AWAY-CMP'
        elif pc != '0' and lc == '0': cls = 'TOWARD-CMP'
        elif pc != '0': cls = 'STAGE1-MOVED'
        else:
            po, lo = int(P['ob']), int(L['ob'])
            if P['verdict'].startswith('STRICT_EQUAL') and not L['verdict'].startswith('STRICT_EQUAL'): cls='AWAY-EQ'
            elif lo < po: cls = 'TOWARD'
            elif lo > po: cls = 'AWAY-OB'
            else: cls = 'OB-SAME'
    print(cls, rel, P.get('verdict','')[:30], P.get('ob',''), '->', L.get('verdict','')[:30], L.get('ob',''), L.get('fires','') if 'fires' in L else '')
