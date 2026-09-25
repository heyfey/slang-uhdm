"""Shared cluster key rewrite (final.py, evid.py, fullname_classes.py)."""
def rekey(x):
    """analyze.py's key, with two splits: a file facet naming builtin.sv on
    either side (@builtin), and a full-name facet on a non-ref_typespec object
    inside a typespec subtree (@in-typespec, the F02 parent-policy ground)."""
    c = x['cluster']
    if x['facet'] == 'file' and ('builtin.sv' in x['golden'] or 'builtin.sv' in x['ours']):
        p = c.split('|'); p[2] += '@builtin'; c = '|'.join(p)
    if x['facet'] == 'fullname' and x['type'] != 'ref_typespec' and '_typespec' in x['chain']:
        p = c.split('|'); p[2] += '@in-typespec'; c = '|'.join(p)
    return c
