#!/usr/bin/env python3
# tables.py <grid_all.tsv> <downstream_cases.tsv> <fixcheck_all.tsv> <depthblind.tsv>: the README's per-law tables.
# One row per case: law OFF (its switch) -> law ON (landed) on uhdm-cmp lines, strict verdict, record check,
# depth-blind order-blind check, downstream verdict; the refined binary's move; the verdict.
import sys, csv, collections, re
G = {r[0]: r for r in csv.reader(open(sys.argv[1]), delimiter='\t')}
DS = {r[0]: r for r in csv.reader(open(sys.argv[2]), delimiter='\t')}
FX = {r[0]: r for r in csv.reader(open(sys.argv[3]), delimiter='\t')}
OB = {}
for l in open(sys.argv[4]):
    p = l.rstrip('\n').split('\t')
    if len(p) >= 3: OB[p[0]] = (p[1].split('=')[1], p[2].split('=')[1])
def short(v):
    v = v.replace('STRICT_NOTEQUAL_', 'NE ').replace('NOT_EQUAL_stage1', 'stage-1')
    v = re.sub(r'STRICT_EQUAL_\d+_objects', 'EQUAL', v)
    return v
by = collections.OrderedDict()
for k, r in G.items():
    if k == 'case': continue
    law = r[1].split(',')[0]
    by.setdefault(law, []).append(k)
BREAK = {'tn/j03_gen_local_net', 'tn/j12_genfor_local_net', 'fa/g09_dpi_export', 'fa/g15_module_export_first',
         'fa/g16_task_export_first', 'bso/h07_in_ps_bound', 'bso/h09_in_ps_bound_proc', 'bso/h11_ps_bound_direct',
         'bso/h14_ps_bound_literal_param', 'xg/x03_param_struct_arr_bound', 'dfi/d05_byte_elems', 'dfi/d06_shortint',
         'dfi/d07_logic32', 'dfi/d10_integer'}
NOTE = {
 'psb/b01_block_localparam': 'stage-1; the renamed refs match golden, the away lines are golden copies ours lacks (count)',
 'psb/b06_sysfunc_arg': 'stage-1; ours holds 2 copies of the argument where golden holds 1, both renamed to golden\'s name',
 'lpb/l01_sysfunc_parent': 'stage-1; the bound\'s ts ref takes golden\'s `work@dut` (count artifact)',
 'lpb/l02_func_arg': 'stage-1; golden keeps the bound UNFOLDED (`ref_obj work@dut.g.a.L`); the law renames our folded copy, neither form in golden',
 'uop/o01_reduction_and': 'stage-1; golden folds the whole reduction `&M` to one constant; the law renames an operand golden lacks',
 'esc/y01_func_name': 'stage-1; every moved column now equals golden\'s; ours holds more copies (count)',
 'esc/y03_struct_member': 'end columns now golden\'s; the escaped member\'s START (golden 5:12, the path start) is a residue',
 'esc/y14_param_value_after': 'escaped parameter end 3:20 -> 3:24, golden 3:26 (v11u146 residue 3): closer, not equal',
 'pi/w02_split_reg_decl': 'stage-1; golden writes NO initializer for `output b; reg b = 0;`, the law relocates one ours invents',
 'tn/j01_two_param_bound': 'walk equal; the away line is our extra weaklyReferenced copy (pre-existing)',
 'tn/j02_packed_2d': 'walk equal; our extra weaklyReferenced copy', 'tn/j05_nonansi': 'walk equal; our extra weaklyReferenced copy',
 'tn/j06_elab': 'walk equal; our extra weaklyReferenced copy', 'tn/j13_genlocal_and_module_ctl': 'the module-level Lhs keeps the law (control); our extra weaklyReferenced copy',
 'tp/q05_nonansi': 'walk equal; our 3 extra weaklyReferenced copies (golden 3 at the keyword, ours 6)',
 'tp/q06_elab': 'walk equal; our 3 extra weaklyReferenced copies',
 'ucp/v02_mixed': 'stage-1; b\'s elaborated LowConn: golden 2:14 (header), off 3:10, on 8:5 (the actual): wrong -> other wrong (residue)',
 'e148/q05_default_fill_import': 'E148 does not fire (an imported package parameter select, golden keeps the call); DEFFILLIMP moves toward',
 'fa/g07_dpi_then_func': 'golden moves to the ordinary function\'s argument; ours holds more copies (count)',
 'fa/g08_func_then_dpi': 'as g07', 'dfi/d08_int_sized_ctl': 'stage-1 int element: expanded in golden, wrong -> other wrong',
 'bso/h16_ps_bound_struct_var': 'stage-1; golden folds `$bits(...)` (no ref at all)',
}
for law in sorted(by):
    print(f'\n#### {"law" if law.endswith("153v") else "§"} {law}\n')
    print('| case | strict off -> on | cmp lines | records away/toward | depth-blind dump away/toward | downstream off -> on (fix) | fix | verdict |')
    print('|---|---|---|---|---|---|---|---|')
    for k in sorted(by[law]):
        r = G[k]; off, on = short(r[3]).split('|'), short(r[4]).split('|')
        cmpl = (off[1] if len(off) > 1 else '-').replace('cmp', '') + ' / ' + (on[1] if len(on) > 1 else '-').replace('cmp', '')
        m = re.match(r'away=(\d+) toward=(\d+)', r[5]); rec = f'{m.group(1)}/{m.group(2)}' if m else '-'
        ob = '/'.join(OB.get(k, ('-', '-')))
        ds = DS.get(k, ['', '-', '-', '-'])
        dso, dsn, dsf = (x.split('|')[0] for x in ds[1:4])
        dsc = dso if dso == dsn else f'{dso} -> {dsn}'
        if dsf != dsn: dsc += f' ({dsf})'
        fx = FX.get(k, ['', '', '', '-'])[3]
        if r[2] == 'still': v = 'law does not fire (bytes equal)'
        elif k in BREAK: v = '**BREAK** (refined)'
        elif k in NOTE: v = 'no break: ' + NOTE[k]
        else: v = 'toward (or neutral)'
        print(f'| `{k}` | {off[0]} -> {on[0]} | {cmpl} | {rec} | {ob} | {dsc} | {fx} | {v} |')
