#!/usr/bin/env python3
"""r10v226 — INDEPENDENT process census over a uhdm-dump.

Walks the dump by INDENTATION (not by the implementer's parser) and emits one
CELL line per (section, scope, position) holding a vpiProcess, plus a
NO-PROCESS line for every instance-like scope that holds none — so an EMPTY
holder is a measured cell, not an absence.

Payload is the process node's TYPE plus its normalised subtree: file paths are
stripped, the vpiParent back-reference block is dropped (it is a back-edge, not
payload), and every remaining line is kept in order.  usage:
    v226_proccen.py <dump> [--payload]
"""
import sys, re, hashlib

INSTKINDS = ('module_inst', 'interface_inst', 'program', 'checker_inst',
             'package', 'gen_scope', 'gen_scope_array')


def indent(line):
    n = 0
    while n < len(line) and line[n] == ' ':
        n += 1
    return n


def load(path):
    out = []
    for raw in open(path, errors='replace'):
        line = raw.rstrip('\n')
        out.append((indent(line), line.strip()))
    return out


def norm(s):
    s = re.sub(r'file:[^,]*', 'file:X', s)
    s = re.sub(r'/[^ ,()]*/', '/X/', s)
    return s


def main():
    path = sys.argv[1]
    show = '--payload' in sys.argv
    lines = load(path)
    section = ''
    # stack of (indent, kind, name) for instance-like scopes
    stack = []
    # pending field label at a given indent
    counters = {}
    i = 0
    seen_scopes = []
    while i < len(lines):
        ind, txt = lines[i]
        m = re.match(r'\|uhdm(\w+):', txt)
        if m:
            section = m.group(1)
            i += 1
            continue
        # a scope header
        m = re.match(r'\\_(\w+): *(.*)', txt)
        if m:
            kind, rest = m.group(1), m.group(2)
            # is this a real child node, or the vpiParent back-reference?
            prev = lines[i - 1][1] if i else ''
            if prev == '|vpiParent:':
                i += 1
                continue
            nm = ''
            mm = re.match(r'([^,(]*)', rest)
            if mm:
                nm = mm.group(1).strip()
            if not nm:
                mm = re.search(r'\(([^)]*)\)', rest)
                nm = mm.group(1) if mm else ''
            if kind in INSTKINDS:
                while stack and stack[-1][0] >= ind:
                    stack.pop()
                key = '%s/%s' % (section, nm or '?')
                stack.append((ind, kind, key))
                counters[key] = 0
                seen_scopes.append(key)
            elif prev == '|vpiProcess:' and stack:
                # a PROCESS of the innermost enclosing scope
                skey = stack[-1][2]
                counters[skey] = counters.get(skey, 0) + 1
                pos = counters[skey]
                # collect the subtree
                body = []
                j = i
                base = ind
                skipdepth = None
                while j < len(lines):
                    jind, jtxt = lines[j]
                    if j > i and jind <= base:
                        break
                    if skipdepth is not None:
                        if jind > skipdepth:
                            j += 1
                            continue
                        skipdepth = None
                    if jtxt == '|vpiParent:':
                        skipdepth = jind
                        j += 1
                        continue
                    body.append('%d %s' % (jind - base, norm(jtxt)))
                    j += 1
                payload = '\n'.join(body)
                h = hashlib.sha1(payload.encode()).hexdigest()[:10]
                loc = re.search(r'line:(\d+):(\d+)', rest)
                locs = '%s:%s' % (loc.group(1), loc.group(2)) if loc else '-'
                print('CELL %s#%d | %s @%s h=%s n=%d' %
                      (skey, pos, kind, locs, h, len(body)))
                if show:
                    print(payload)
        i += 1
    for k in seen_scopes:
        if counters.get(k, 0) == 0:
            print('CELL %s#0 | NO-PROCESS' % k)


main()
