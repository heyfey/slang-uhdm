#!/usr/bin/env python3
"""allsw.py [--elab] <casedir>...: every single switch of the three landings; prints the switches that move the case's
bytes (vs law on) and the judge verdict (switch off -> on)."""
import sys, os, json, subprocess
H=os.path.dirname(os.path.abspath(__file__))
SW=['R11U133_LHSCLONE_OFF','R11U133_HPMID_OFF','R11U133_TRAILIDX_OFF','R11U133_PATQUAL_OFF','R11U133_UNKFILE_OFF',
    'R11V141_INCTABACT_OFF','R11V141_IPSQUAL_OFF','R11U137_ELABCLONE_OFF','R11U137_ELABCLONE_PKG_OFF','R11U137_PATD_OFF','R11U137_EMPTYCONN_OFF',
    'R11U137_UNSIGNEDSPAN_OFF','R11U137_CALLSPAN_OFF','R11U137_REPLTSNAME_OFF','R11U137_PUREVIRTSPAN_OFF','R11U137_TAGGEDSPAN_OFF',
    'R11U137_DEFNETTP_OFF','R11U137_ALIASFILE_OFF','R11U137_SCOPEDARRTD_OFF','R11U137_PATHBASE_OFF','R11U139_CA_OFF','R11U139_NDA_OFF',
    'R11U139_CLK_OFF','R11U139_PORT_OFF','R11V137_DEFWIRE_OFF','R11V137_PVQUAL_OFF']
a=sys.argv[1:]; el=[]
if a[0]=='--elab': el=['--elab']; a=a[1:]
for c in a:
    r=json.loads(subprocess.run(['python3',f'{H}/case.py']+el+[c,'ON=']+[f'S{i}={s}' for i,s in enumerate(SW)],capture_output=True,text=True).stdout)
    mv=[]
    for i,s in enumerate(SW):
        x=r[f'S{i}']
        if x.get('md5')!=r['ON'].get('md5'):
            v=subprocess.run(['python3',f'{H}/judge.py',f'/tmp/r11u143_cases/{r["key"]}',f'S{i}','ON'],capture_output=True,text=True).stdout.strip()
            if v.startswith('STAGE1'): v='STAGE1 '+subprocess.run(['python3',f'{H}/dd.py',f'/tmp/r11u143_cases/{r["key"]}',f'S{i}','ON'],capture_output=True,text=True).stdout.strip()[:160]
            mv.append(f'{s}: {v.split(" P=")[0]}')
    print('/'.join(c.rstrip('/').split('/')[-2:]),('elab' if el else 'default'),'|',' ; '.join(mv) or 'no switch moves it')
