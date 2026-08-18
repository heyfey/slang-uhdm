#!/usr/bin/env python3
"""r10vrgg11 adversarial grid generator.  Writes one cell dir per combination."""
import os, sys, re

OUT = sys.argv[1]
WHICH = sys.argv[2]

SINK = """module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module sinkw (input logic [63:0] i_value);
endmodule
module sinkr (input real i_value);
endmodule
module sinks (input string i_value);
endmodule
"""

FUNCS = """  function automatic bit [7:0] f8(input bit [7:0] a);
    return a;
  endfunction
"""

TYPES = {
 'bit8':      'bit [7:0]',
 'logic8':    'logic [7:0]',
 'sbit8':     'bit signed [7:0]',
 'int':       'int',
 'integer':   'integer',
 'untyped':   '',
 'bit1':      'bit',
 'bit32':     'bit [31:0]',
 'byte':      'byte',
 'longint':   'longint',
 'real':      'real',
 'string':    'string',
 'td':        't_t',
 'enum':      'e_t',
 'p2d':       'bit [3:0][1:0]',
}
REALTYPES = {'real'}
STRTYPES = {'string'}

INITS = {
 'hex8':      "8'hab",
 'bin8':      "8'b10101011",
 'oct8':      "8'o253",
 'dec8':      "8'd171",
 'plain':     "171",
 'neg':       "-3",
 'negsized':  "-8'sd3",
 'ssigned':   "8'shab",
 'unsized':   "'hab",
 'xval':      "8'hx",
 'zval':      "8'bz",
 'usc':       "8'b1010_1011",
 'realv':     "1.5",
 'strv':      '"ab"',
 'cat':       "{4'ha,4'hb}",
 'repl':      "{2{4'ha}}",
 'cast':      "8'(171)",
 'call':      "f8(8'hab)",
 'clog':      "$clog2(300)",
 'expr':      "8'h0a+8'ha1",
 'paramexpr': "BASE+1",
 'outerparam':"PW",
 'enumval':   "E1",
 'tern':      "1 ? 8'hab : 8'h00",
 'huge':      "64'hdeadbeefcafe0011",
 'z1':        "1'b1",
}

# reads: how IV is consumed
READS = {
 'portplain':  ".i_value(IV)",
 'portpos':    None,   # special
 'portcat':    ".i_value({4'h0, IV[3:0]})",
 'portcast':   ".i_value(8'(IV))",
 'portsel':    ".i_value(IV[3:0])",
 'portcall':   ".i_value(f8(IV))",
 'porttern':   ".i_value(1 ? IV : 8'h0)",
 'portop':     ".i_value(IV+0)",
 'portrepl':   ".i_value({2{IV[3:0]}})",
 'portsys':    ".i_value($clog2(IV))",
 'portconc':   ".i_value({IV})",
}

def home_wrap(home, body, decl):
    """returns the text placed in module top."""
    if home == 'mod':
        return decl + "\n" + body
    if home == 'genif':
        return "  if (1) begin : g\n%s\n%s\n  end\n" % (decl, body)
    if home == 'genifelse':
        return "  if (0) begin : gx\n  end else begin : g\n%s\n%s\n  end\n" % (decl, body)
    if home == 'genfor':
        return "  for (genvar gi = 0; gi < 1; gi++) begin : g\n%s\n%s\n  end\n" % (decl, body)
    if home == 'genfor3':
        return "  for (genvar gi = 0; gi < 3; gi++) begin : g\n%s\n%s\n  end\n" % (decl, body)
    if home == 'genforext':
        return "  genvar gi;\n  for (gi = 0; gi < 1; gi++) begin : g\n%s\n%s\n  end\n" % (decl, body)
    if home == 'gencase':
        return "  case (1)\n    1: begin : g\n%s\n%s\n    end\n  endcase\n" % (decl, body)
    if home == 'nestin':
        return "  if (1) begin : g0\n    if (1) begin : g\n%s\n%s\n    end\n  end\n" % (decl, body)
    if home == 'nestouter':
        return "  if (1) begin : g\n%s\n    if (1) begin : g1\n%s\n    end\n  end\n" % (decl, body)
    if home == 'genblkanon':
        return "  if (1) begin\n%s\n%s\n  end\n" % (decl, body)
    raise SystemExit('home? ' + home)

def sink_for(tname):
    if tname in REALTYPES: return 'sinkr'
    if tname in STRTYPES: return 'sinks'
    return 'sink'

def mk(name, text):
    d = os.path.join(OUT, name)
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'top.sv'), 'w').write(text)

PRE = """typedef bit [7:0] t_t;
typedef enum bit [7:0] { E0 = 8'h0a, E1 = 8'hab } e_t;
"""

def cell(name, home, tname, iname, read='portplain', extra_top='', ninst=1,
         module_params="#(parameter int PW = 170)", inst_params="#(.PW(170))"):
    ty = TYPES[tname]; iv = INITS[iname]
    decl = "    localparam int BASE = 170;\n    localparam %s IV = %s;" % (ty, iv)
    sk = sink_for(tname)
    if read == 'portplain':
        body = "\n".join("    %s #(8) u%d (.i_value(IV));" % (sk, k) for k in range(ninst)) \
               if sk == 'sink' else \
               "\n".join("    %s u%d (.i_value(IV));" % (sk, k) for k in range(ninst))
    elif read == 'portpos':
        body = "    %s #(8) u0 (IV);" % sk
    elif read == 'pov':
        body = "    sink #(.W(IV)) u0 (.i_value(8'h0));"
    elif read == 'povexpr':
        body = "    sink #(.W(IV+1)) u0 (.i_value(8'h0));"
    elif read == 'defparam':
        body = "    sink u0 (.i_value(8'h0));\n    defparam u0.W = IV;"
    elif read == 'ca':
        body = "    logic [7:0] w;\n    assign w = IV;"
    elif read == 'proc':
        body = "    logic [7:0] w;\n    always_comb w = IV;"
    elif read == 'gencond':
        body = "    if (IV) begin : gg\n      sink #(8) u0 (.i_value(8'h0));\n    end"
    elif read == 'arrinst':
        body = "    sink #(8) u0 [2] (.i_value(IV));"
    elif read == 'none':
        body = "    logic [7:0] w;\n    assign w = 8'h0;"
    elif read == 'twoinst':
        body = "    sink #(8) u0 (.i_value(IV));\n    sink #(8) u1 (.i_value(IV));"
    else:
        body = "    %s #(8) u0 (%s);" % (sk, READS[read])
    inner = home_wrap(home, body, decl)
    txt = PRE + SINK + extra_top + "module top %s;\n%s\n%s\nendmodule\n" % (module_params, FUNCS, inner)
    mk(name, txt)

if WHICH == 'V1':   # type axis, 10 homes x 15 types, init hex8 (adjusted per type)
    homes = ['mod','genif','genifelse','genfor','genfor3','genforext','gencase','nestin','nestouter','genblkanon']
    for h in homes:
        for t in TYPES:
            i = 'hex8'
            if t == 'real': i = 'realv'
            if t == 'string': i = 'strv'
            if t == 'enum': i = 'enumval'
            cell('%s__%s__%s__portplain' % (h, t, i), h, t, i)
elif WHICH == 'V2':  # init axis, 3 homes x all inits, type bit8 + untyped
    for h in ['mod','genif','genfor']:
        for t in ['bit8','untyped']:
            for i in INITS:
                if t == 'bit8' and i in ('realv','strv'): continue
                cell('%s__%s__%s__portplain' % (h, t, i), h, t, i)
elif WHICH == 'V3':  # read axis
    reads = list(READS.keys()) + ['pov','povexpr','defparam','ca','proc','gencond','arrinst','none','twoinst']
    for h in ['genif','genfor','mod']:
        for t in ['bit8','int','untyped']:
            for r in reads:
                cell('%s__%s__hex8__%s' % (h, t, r), h, t, 'hex8', read=r)
