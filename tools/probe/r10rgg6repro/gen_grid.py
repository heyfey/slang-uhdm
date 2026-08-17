#!/usr/bin/env python3
"""r10rgg6/gen_grid.py -- build the golden-measurement grid for the
§ elabParamTsRebind ELAB arm (the Rggen head: our ref_typespec on the
elaborated `get_sub_n_list(N)` param-initializer call that golden leaves bare).

Every cell is ONE self-contained .sv in its own directory, so Surelog's
`default`-mode argv is exactly `-parse <file>` -- the same argv shape
verify_golden.py hands the corpus.

The BODY is rggen_or_reducer's, verbatim except for the axes named below, so a
cell that reproduces FuncInModule's stamp and a cell that reproduces Rggen's
bare call differ ONLY in the axis under test.

AXES
  topo   top     M is the top module, no instantiation      (FuncInModule)
         one     a wrapper instantiates ONE M
         two     a wrapper instantiates TWO Ms, same N
         twoN    a wrapper instantiates TWO Ms, different N
         genfor  a generate-for instantiates 3 Ms
         rec     M instantiates ITSELF under `if (P3 > 1)`  (Rggen)
  third  p1      P3 = f3(P1)   -- Rggen's `get_next_n(SUB_N_LIST)`
         p2      P3 = f3(P2)   -- FuncInModule's `get_next_n(OFFSET_LIST)`
         none    no third localparam at all
  n      the N the instance is elaborated with
  fold   yes     f1's body is rggen's (Surelog folds it, corruptly)
         no      f1's body calls $random-free but unevaluable code
  formal typed   f2/f3's formal is `bit [N-1:0][15:0] a`
         untyped f2/f3's formal is an untyped `input a` (implicit)
  site   param   P1 is consumed by a param-initializer call     (Rggen)
         ca      P1 is consumed by a continuous-assign call
         proc    P1 is consumed by a procedural (always_comb) call
  two_ts P1 passed to TWO functions with DIFFERENT formal typespecs
"""
import os, sys, itertools, shutil

ROOT = os.path.dirname(os.path.abspath(__file__))

F1_FOLD = """  function automatic bit [N-1:0][15:0] f1(int n);
    bit [N-1:0][15:0] list;
    int               list_index;
    bit [15:0]        current_n;
    bit [15:0]        half_n;

    list        = '0;
    list_index  = 0;
    current_n   = 16'(n);
    while (current_n > 0) begin
      half_n  = current_n / 2;
      if ((current_n > 4) && (half_n <= 4)) begin
        list[list_index]  = half_n;
      end
      else if (current_n >= 4) begin
        list[list_index]  = 4;
      end
      else begin
        list[list_index]  = current_n;
      end

      current_n   -= list[list_index];
      list_index  += 1;
    end

    return list;
  endfunction
"""

# An f1 Surelog cannot evaluate at all: it reads a module-level VARIABLE.
F1_NOFOLD = """  logic [15:0] opaque_v;
  function automatic bit [N-1:0][15:0] f1(int n);
    bit [N-1:0][15:0] list;
    list = '0;
    list[0] = opaque_v + 16'(n);
    return list;
  endfunction
"""

def f2(formal):
    a = "bit [N-1:0][15:0] sub_n_list" if formal == 'typed' else "sub_n_list"
    return """  function automatic bit [N-1:0][15:0] f2(%s);
    bit [N-1:0][15:0] list;

    for (int i = 0;i < N;++i) begin
      if (i == 0) begin
        list[i] = 0;
      end
      else begin
        list[i] = sub_n_list[i-1] + list[i-1];
      end
    end

    return list;
  endfunction
""" % a

def f3(formal):
    a = "bit [N-1:0][15:0] sub_n_list" if formal == 'typed' else "sub_n_list"
    return """  function automatic int f3(%s);
    int next_n;

    next_n  = 0;
    for (int i = 0;i < N;++i) begin
      next_n  += ((sub_n_list[i] != 0) ? 1 : 0);
    end

    return next_n;
  endfunction
""" % a

# a THIRD function whose formal typespec is DIFFERENT from f2's (16 bits wide,
# one dimension) -- the "last wins" probe.
F4 = """  function automatic int f4(bit [15:0] narrow_v);
    return int'(narrow_v);
  endfunction
"""

def body(cell):
    n      = cell['n']
    third  = cell['third']
    formal = cell['formal']
    site   = cell['site']
    s  = "module m #(\n  parameter int WIDTH = 2,\n  parameter int N = %d\n)(\n" % n
    s += "  input   logic [N-1:0][WIDTH-1:0]  i_data,\n"
    s += "  output  logic [WIDTH-1:0]         o_result\n);\n"
    s += (F1_NOFOLD if cell['fold'] == 'no' else F1_FOLD)
    s += "\n" + f2(formal)
    s += "\n" + f3(formal)
    if cell.get('two_ts'):
        s += "\n" + F4
    s += "\n  localparam  bit [N-1:0][15:0] P1 = f1(N);\n"
    if site == 'param':
        s += "  localparam  bit [N-1:0][15:0] P2 = f2(P1);\n"
        if third == 'p1':
            s += "  localparam  int               P3 = f3(P1);\n"
        elif third == 'p2':
            s += "  localparam  int               P3 = f3(P2);\n"
        else:
            s += "  localparam  int               P3 = 2;\n"
        if cell.get('two_ts'):
            s += "  localparam  int               P4 = f4(P1);\n"
    elif site == 'ca':
        # P1 reaches f2 through a CONTINUOUS ASSIGN, never a param initializer
        s += "  localparam  int               P3 = 2;\n"
        s += "  wire [N-1:0][15:0] w2;\n  assign w2 = f2(P1);\n"
    elif site == 'proc':
        s += "  localparam  int               P3 = 2;\n"
        s += "  logic [N-1:0][15:0] r2;\n"
        s += "  always_comb begin\n    r2 = f2(P1);\n  end\n"
    s += "\n  logic [P3-1:0][WIDTH-1:0] next_data;\n"
    s += "\n  always_comb begin\n    for (int i = 0;i < P3;++i) begin\n"
    s += "      next_data[i]  = i_data[0];\n    end\n  end\n"
    if cell['topo'] == 'rec':
        s += """
  generate
    if (P3 > 1) begin : g_reduce
      m #(
        .WIDTH  (WIDTH  ),
        .N      (P3     )
      ) u_reducer (
        .i_data   (next_data  ),
        .o_result (o_result   )
      );
    end
    else begin : g_reduce
      always_comb begin
        o_result  = next_data[0];
      end
    end
  endgenerate
"""
    else:
        s += "\n  always_comb begin\n    o_result = next_data[0];\n  end\n"
    s += "endmodule\n"

    topo = cell['topo']
    if topo == 'top':
        return s
    s += "\nmodule top(\n  input logic [63:0][1:0] d,\n  output logic [1:0] q0, output logic [1:0] q1, output logic [1:0] q2\n);\n"
    if topo in ('one', 'rec'):
        s += "  m #(.WIDTH(2), .N(%d)) u0 (.i_data(d[%d-1:0]), .o_result(q0));\n" % (n, n)
        s += "  assign q1 = q0; assign q2 = q0;\n"
    elif topo == 'two':
        s += "  m #(.WIDTH(2), .N(%d)) u0 (.i_data(d[%d-1:0]), .o_result(q0));\n" % (n, n)
        s += "  m #(.WIDTH(2), .N(%d)) u1 (.i_data(d[%d-1:0]), .o_result(q1));\n" % (n, n)
        s += "  assign q2 = q0;\n"
    elif topo == 'twoN':
        s += "  m #(.WIDTH(2), .N(%d)) u0 (.i_data(d[%d-1:0]), .o_result(q0));\n" % (n, n)
        n2 = 5 if n != 5 else 9
        s += "  m #(.WIDTH(2), .N(%d)) u1 (.i_data(d[%d-1:0]), .o_result(q1));\n" % (n2, n2)
        s += "  assign q2 = q0;\n"
    elif topo == 'genfor':
        s += "  logic [1:0] qq [3];\n"
        s += "  generate\n    for (genvar gi = 0; gi < 3; gi++) begin : g\n"
        s += "      m #(.WIDTH(2), .N(%d)) u (.i_data(d[%d-1:0]), .o_result(qq[gi]));\n" % (n, n)
        s += "    end\n  endgenerate\n"
        s += "  assign q0 = qq[0]; assign q1 = qq[1]; assign q2 = qq[2];\n"
    s += "endmodule\n"
    return s


def cellname(c):
    return "%s_%s_n%d_%s_%s_%s%s" % (c['topo'], c['third'], c['n'], c['fold'],
                                     c['formal'], c['site'],
                                     '_2ts' if c.get('two_ts') else '')

def cells():
    out = []
    D = dict(topo='top', third='p2', n=4, fold='yes', formal='typed',
             site='param')
    def add(**kw):
        c = dict(D); c.update(kw); out.append(c)
    # A. topology sweep, FuncInModule's third-arg (p2) and Rggen's (p1)
    for topo in ('top', 'one', 'two', 'twoN', 'genfor', 'rec'):
        for third in ('p2', 'p1', 'none'):
            add(topo=topo, third=third)
    # B. N sweep at the two extreme topologies
    for n in (2, 5, 20, 25):
        for topo in ('top', 'one'):
            for third in ('p2', 'p1'):
                add(topo=topo, third=third, n=n)
    # C. foldable vs symbolic Rhs
    for fold in ('yes', 'no'):
        for topo in ('top', 'one'):
            for third in ('p2', 'p1'):
                add(topo=topo, third=third, fold=fold)
    # D. formal typed vs untyped
    for formal in ('typed', 'untyped'):
        for topo in ('top', 'one'):
            add(topo=topo, third='p2', formal=formal)
    # E. consumption site
    for site in ('param', 'ca', 'proc'):
        for topo in ('top', 'one'):
            add(topo=topo, site=site, third='none')
    # F. two functions, different formal typespecs (LAST wins?)
    for topo in ('top', 'one'):
        for third in ('p2', 'p1'):
            add(topo=topo, third=third, two_ts=True)
    seen, uniq = set(), []
    for c in out:
        k = cellname(c)
        if k in seen: continue
        seen.add(k); uniq.append(c)
    return uniq


def main():
    cs = cells()
    for c in cs:
        d = os.path.join(ROOT, 'cells', cellname(c))
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'wt') as f:
            f.write(body(c))
    print(len(cs), 'cells')

if __name__ == '__main__':
    main()
