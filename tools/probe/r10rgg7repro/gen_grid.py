#!/usr/bin/env python3
"""r10rgg7/gen_grid.py -- the golden grid for § genIfUnvaluedFuncParam7.

ONE QUESTION per cell: a conditional generate whose two arms are BOTH named
`g_reduce` (exactly Rggen's shape) and are told apart by their CONTENT
(`a_mark` in the if arm, `b_mark` in the else arm) -- which arm does REAL
SURELOG elaborate, and which does slang?

Axes:
  * how the condition's parameter is produced: a poisoning const function
    (Surelog's ExprEval bails), the Rggen saturated-array pair, a foldable
    call, a plain literal, $clog2, a package parameter, the instance's own N;
  * N in {1,2,3,4,5,8,20,25};
  * the CONDITION's shape: `> 1`, `== 1`, `!= 1`, `< 1` -- so "the condition is
    FALSE" is separable from "the identifier reads 0";
  * the arm CONTENT: markers, a real nested instantiation, a generate-for.

Every cell writes <cell>/dut.sv and nothing else.
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CELLS_DIR = os.path.join(HERE, 'cells')

# ---------------------------------------------------------------- fragments
# A function whose body DEFEATS Surelog's ExprEval (a select of a function-scope
# object under a poison-propagating operator: `l[i] != 0`).  This is exactly
# rggen_or_reducer's get_next_n.
POIS_CNT = """  function automatic int cnt(bit [%(NB)s:0][15:0] l);
    int r;
    r = 0;
    for (int i = 0;i < %(NN)s;++i) begin
      r += ((l[i] != 0) ? 1 : 0);
    end
    return r;
  endfunction
"""

# The same counting written so NOTHING poisons: a plain accumulate over an
# argument, no select of a function-scope object under a poison operator.
FOLD_ADD = """  function automatic int addup(int n);
    int r;
    r = 0;
    for (int i = 0;i < n;++i) begin
      r += 1;
    end
    return r;
  endfunction
"""

# Rggen's get_sub_n_list: the compound write-back that ESCAPES (§
# compoundLitWriteBackSat2) and corrupts the array (§ satArrArgFirstElem5).
SUBN = """  function automatic bit [%(NB)s:0][15:0] get_sub_n_list(int n);
    bit [%(NB)s:0][15:0] list;
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

ARM_MARK = """    if (%(COND)s) begin : g_reduce
      logic a_mark;
      always_comb begin
        a_mark = 1'b1;
      end
    end
    else begin : g_reduce
      logic b_mark;
      always_comb begin
        b_mark = 1'b0;
      end
    end
"""

LEAF = """module leaf(output logic o);
  always_comb begin
    o = 1'b1;
  end
endmodule

"""

# The if arm holds a REAL instantiation.  It must NOT be `sub` itself: in the
# pattern family NEXT does not shrink with N, so a self-instantiation is
# infinitely recursive and slang rejects the whole design (measured: cell
# a_pat_inst produced NO slang database at all).  `leaf` keeps the axis --
# "the arm contains a module_inst" -- with no recursion.
ARM_INST = """    if (%(COND)s) begin : g_reduce
      leaf u_leaf (.o(o_result));
    end
    else begin : g_reduce
      logic b_mark;
      always_comb begin
        b_mark = 1'b0;
      end
    end
"""

ARM_FOR = """    if (%(COND)s) begin : g_reduce
      for (genvar gi = 0;gi < 2;++gi) begin : gl
        logic a_mark;
        always_comb begin
          a_mark = 1'b1;
        end
      end
    end
    else begin : g_reduce
      logic b_mark;
      always_comb begin
        b_mark = 1'b0;
      end
    end
"""


def mod_sub(n, produce, cond, arm, extra=''):
    """The `sub` module: one localparam NEXT produced `produce`-wise, one
    conditional generate on `cond`."""
    # The SAT family is written exactly as rggen_or_reducer writes it -- every
    # width and loop bound reads the PARAMETER N, so one definition serves
    # instances of different N.  The pattern family keeps literal counts (its
    # '{...} initialiser has a fixed element count and could not be shared).
    symN = produce == 'pois_sat'
    d = {'NB': ('N-1' if symN else str(max(n - 1, 0))),
         'NN': ('N' if symN else str(n)), 'COND': cond}
    fns = ''
    body = ''
    if produce == 'pois_pattern':
        fns = POIS_CNT % d
        body = ('  localparam bit [%d:0][15:0] LIST = \'{%s};\n'
                '  localparam int NEXT = cnt(LIST);\n'
                % (max(n - 1, 0), ','.join(["16'd%d" % (i + 1) for i in range(n)])))
    elif produce == 'pois_sat':
        fns = SUBN % d + POIS_CNT % d
        body = ('  localparam bit [N-1:0][15:0] LIST = get_sub_n_list(N);\n'
                '  localparam int NEXT = cnt(LIST);\n')
    elif produce == 'pois_noarg':
        fns = ("  function automatic int cnt0();\n"
               "    bit [7:0][15:0] l;\n"
               "    int r;\n"
               "    l = '0;\n"
               "    r = 0;\n"
               "    for (int i = 0;i < 8;++i) begin\n"
               "      r += ((l[i] != 0) ? 1 : 0);\n"
               "    end\n"
               "    r += 7;\n"
               "    return r;\n"
               "  endfunction\n")
        body = '  localparam int NEXT = cnt0();\n'
    elif produce == 'fold_call':
        fns = FOLD_ADD
        body = '  localparam int NEXT = addup(%d);\n' % n
    elif produce == 'plain':
        body = '  localparam int NEXT = %d;\n' % n
    elif produce == 'clog2':
        body = '  localparam int NEXT = $clog2(%d) + 1;\n' % (n * 4 + 1)
    elif produce == 'pkgparam':
        body = '  localparam int NEXT = grid_pkg::PKG_N;\n'
    elif produce == 'ownN':
        body = '  localparam int NEXT = N;\n'
    elif produce == 'mdpacked':
        # a MULTIDIMENSIONAL PACKED parameter whose function FOLDS: Surelog
        # never rewrites such a param_assign's Rhs (packedDimCount >= 2), so
        # this cell asks whether the KEPT Rhs also means NO VALUE.
        fns = ("  function automatic bit [7:0][15:0] mkfold();\n"
               "    bit [7:0][15:0] l;\n"
               "    for (int i = 0;i < 8;++i) begin\n"
               "      l[i] = 16'd2;\n"
               "    end\n"
               "    return l;\n"
               "  endfunction\n")
        body = '  localparam bit [7:0][15:0] QQ = mkfold();\n'
    elif produce == 'unevalarg':
        # an ARGUMENT outside ExprEval's system-call repertoire ($floor)
        fns = FOLD_ADD
        body = "  localparam int NEXT = addup(int'($floor(8.7)));\n"
    elif produce == 'declparam':
        # a function body that declares a LOCALPARAM (const_func_block_var)
        fns = ("  function automatic int cntp();\n"
               "    localparam int K = 3;\n"
               "    int r;\n"
               "    r = K + %d;\n"
               "    return r;\n"
               "  endfunction\n" % (n - 3))
        body = '  localparam int NEXT = cntp();\n'
    elif produce == 'pois_argchain':
        # the UNVALUED parameter is the ARGUMENT of a call that DOES fold
        fns = POIS_CNT % d + FOLD_ADD
        body = ('  localparam bit [%d:0][15:0] LIST = \'{%s};\n'
                '  localparam int RAW  = cnt(LIST);\n'
                '  localparam int NEXT = addup(RAW);\n'
                % (max(n - 1, 0), ','.join(["16'd%d" % (i + 1) for i in range(n)])))
    elif produce == 'pkgfunc':
        # the const function lives in a PACKAGE, not in the module body
        body = '  localparam int NEXT = grid_pkg::pkg_cnt();\n'
    elif produce == 'pois_chain':
        # the poisoning parameter is read INDIRECTLY, one localparam down
        fns = POIS_CNT % d
        body = ('  localparam bit [%d:0][15:0] LIST = \'{%s};\n'
                '  localparam int RAW  = cnt(LIST);\n'
                '  localparam int NEXT = RAW + 0;\n'
                % (max(n - 1, 0), ','.join(["16'd%d" % (i + 1) for i in range(n)])))
    else:
        raise SystemExit('bad produce ' + produce)
    return ("module sub #(\n"
            "  parameter int N = %d\n"
            ")(\n"
            "  output logic o_result\n"
            ");\n%s%s%s\n  generate\n%s  endgenerate\nendmodule\n"
            % (n, fns, body, extra, arm % d))


def cell(name, n, produce, cond='NEXT > 1', arm=ARM_MARK, pkg=False, extra='',
         insts=None):
    """`insts` overrides the top's instance list.  TWO OR MORE instances are
    what puts § compoundLitWriteBackSat2's escape into the SATURATED regime
    (r10rgg2 § 2), so the sat family needs both the 1-instance and the
    multi-instance face -- Rggen itself has thirteen."""
    src = ''
    if pkg == 'func':
        src += ("package grid_pkg;\n"
                "  function automatic int pkg_cnt();\n"
                "    bit [7:0][15:0] l;\n"
                "    int r;\n"
                "    l = '0;\n"
                "    r = 0;\n"
                "    for (int i = 0;i < 8;++i) begin\n"
                "      r += ((l[i] != 0) ? 1 : 0);\n"
                "    end\n"
                "    r += %d;\n"
                "    return r;\n"
                "  endfunction\n"
                "endpackage\n\n" % n)
    elif pkg:
        src += ("package grid_pkg;\n  localparam int PKG_N = %d;\nendpackage\n\n"
                % n)
    if arm is ARM_INST:
        src += LEAF
    src += mod_sub(n, produce, cond, arm, extra)
    if insts is None:
        insts = [n]
    lines = ''.join('  logic r%d;\n' % i for i in range(len(insts)))
    lines += ''.join('  sub #(.N(%d)) u%d (.o_result(r%d));\n' % (v, i, i)
                     for i, v in enumerate(insts))
    src += "\nmodule top;\n%sendmodule\n" % lines
    return name, src


CELLS = []
# --- Family P: a POISONING const function, NO saturated array.
for n in (2, 3, 4, 5, 8, 20, 25):
    CELLS.append(cell('p_pat_n%d' % n, n, 'pois_pattern'))
CELLS.append(cell('p_noarg_n8', 8, 'pois_noarg'))
CELLS.append(cell('p_chain_n8', 8, 'pois_chain'))
# --- Family S: the Rggen saturated pair.
for n in (2, 4, 5, 8, 20, 25):
    CELLS.append(cell('s_sat_n%d' % n, n, 'pois_sat'))
# --- Family K: CONDITION SHAPE (separates "condition FALSE" from "reads 0").
for cn, cd in (('gt1', 'NEXT > 1'), ('eq1', 'NEXT == 1'), ('ne1', 'NEXT != 1'),
               ('lt1', 'NEXT < 1'), ('eq0', 'NEXT == 0'), ('bare', 'NEXT')):
    CELLS.append(cell('k_pat_%s' % cn, 8, 'pois_pattern', cond=cd))
    CELLS.append(cell('k_sat_%s' % cn, 25, 'pois_sat', cond=cd))
# --- Family A: the ARM CONTENT.
CELLS.append(cell('a_pat_inst', 8, 'pois_pattern', arm=ARM_INST))
CELLS.append(cell('a_sat_inst', 25, 'pois_sat', arm=ARM_INST))
CELLS.append(cell('a_pat_for', 8, 'pois_pattern', arm=ARM_FOR))
CELLS.append(cell('a_sat_for', 25, 'pois_sat', arm=ARM_FOR))
# --- Family C: CONTROLS.  Surelog CAN value these; slang's arm must stand.
for n in (2, 8, 25):
    CELLS.append(cell('c_plain_n%d' % n, n, 'plain'))
    CELLS.append(cell('c_fold_n%d' % n, n, 'fold_call'))
    CELLS.append(cell('c_clog2_n%d' % n, n, 'clog2'))
    CELLS.append(cell('c_ownN_n%d' % n, n, 'ownN'))
    CELLS.append(cell('c_pkg_n%d' % n, n, 'pkgparam', pkg=True))
# N=1 controls: slang itself takes the ELSE arm, so both sides must agree
# whatever the model says -- a cell that cannot separate is still a cell that
# must not BREAK.
CELLS.append(cell('c_plain_n1', 1, 'plain'))
CELLS.append(cell('c_ownN_n1', 1, 'ownN'))
CELLS.append(cell('p_pat_n1', 1, 'pois_pattern'))
CELLS.append(cell('s_sat_n1', 1, 'pois_sat'))
# --- Family M: MULTI-INSTANCE.  The saturated regime needs >= 2 instances plus
# the r10vrgg2 DEMAND GATE; the poison family gets the same faces so the axis is
# instance count and nothing else.
CELLS.append(cell('m_sat_25_2', 25, 'pois_sat', insts=[25, 2]))
CELLS.append(cell('m_sat_2_25', 25, 'pois_sat', insts=[2, 25]))
CELLS.append(cell('m_sat_25x2', 25, 'pois_sat', insts=[25, 25]))
CELLS.append(cell('m_sat_20_25', 25, 'pois_sat', insts=[20, 25]))
CELLS.append(cell('m_sat_13x', 25, 'pois_sat',
                  insts=[25, 20, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]))
CELLS.append(cell('m_pat_8x2', 8, 'pois_pattern', insts=[8, 8]))
CELLS.append(cell('m_plain_8_2', 8, 'plain', insts=[8, 2]))
CELLS.append(cell('m_fold_8_2', 8, 'fold_call', insts=[8, 2]))
# --- Family X: two REACH faces the implementation has to choose.
CELLS.append(cell('x_argchain_n8', 8, 'pois_argchain'))
CELLS.append(cell('x_pkgfunc_n8', 8, 'pkgfunc', pkg='func'))
# --- Family Y: the OTHER three clauses of the "Rhs stayed a func_call" gate,
# each measured on its own so the predicate's clause set is not assumed.
CELLS.append(cell('y_mdpacked_n8', 8, 'mdpacked', cond='QQ[0] > 1'))
CELLS.append(cell('y_unevalarg_n8', 8, 'unevalarg'))
CELLS.append(cell('y_declparam_n8', 8, 'declparam'))


def main():
    os.makedirs(CELLS_DIR, exist_ok=True)
    for name, src in CELLS:
        d = os.path.join(CELLS_DIR, name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'wt') as f:
            f.write(src)
    print('cells=%d' % len(CELLS))
    names = [n for n, _ in CELLS]
    assert len(set(names)) == len(names), 'DUPLICATE CELL NAME'


if __name__ == '__main__':
    main()
