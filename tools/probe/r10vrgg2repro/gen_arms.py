#!/usr/bin/env python3
"""r10vrgg2 (r10rgg2's adversarial verifier) — the arm generator.

Every cell is a whole two-file design (`dut.sv` + `top.sv`) whose golden is REAL
Surelog.  The cell under measurement is always the integer literal on the
right-hand side of the statement-level compound assignment inside the
constant-evaluated function (`run_arm.sh` locates it from the source, so a cell
can never be read at the wrong position).

The cells are organised by the QUESTION they answer:

  x*  the PRIME ATTACK: the v1 shape (a localparam whose only consumer is a
      continuous assign) at >= 2 elaborated instances.  Surelog evaluates the
      function ZERO times here, so golden keeps the WRITTEN literal.
  z*  the DEMAND boundary: what kind of consumer makes Surelog fold at all.
  y*  the brief's list: nested const functions, recursion, dual const/non-const
      use, several compound assigns, -= *= <<= %=, a narrow index, a sized
      literal, a param-dependent loop count, a package function.
  w*  the DEMANDED (saturating) shape, perturbed: sized/hex/binary literals,
      a narrow index, a second compound literal, 3 instances, and the N=2 / N=4
      regime-1 cells that are the corpus canaries.
"""
import os

FN_HDR = '''module orv #(
  parameter int WIDTH = 2,
  parameter int N     = 20
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
'''
FN = '''  function automatic bit [N-1:0][15:0] get_sub_n_list(int n);
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
'''
OFF = '''  function automatic bit [N-1:0][15:0] get_offset_list(bit [N-1:0][15:0] sub_n_list);
    bit [N-1:0][15:0] list;
    for (int i = 0;i < N;++i) begin
      if (i == 0) list[i] = 0;
      else        list[i] = sub_n_list[i-1] + list[i-1];
    end
    return list;
  endfunction
'''
NEXTFN = '''  function automatic int get_next_n(bit [N-1:0][15:0] sub_n_list);
    int next_n;
    next_n  = 0;
    for (int i = 0;i < N;++i) next_n += ((sub_n_list[i] != 0) ? 1 : 0);
    return next_n;
  endfunction
'''
LP = '  localparam  bit [N-1:0][15:0] SUB_N_LIST  = get_sub_n_list(N);\n'
ASSIGN = '  assign o_result = SUB_N_LIST[0][WIDTH-1:0];\nendmodule\n'


def w(d, dut, k=2, n=25, mod='orv'):
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, 'dut.sv'), 'wt') as f:
        f.write(dut)
    s = 'module top;\n'
    for i in range(k):
        s += '  %s #(.WIDTH(2), .N(%d)) u%d (.i_data(), .o_result());\n' % (mod, n, i)
    with open(os.path.join(d, 'top.sv'), 'wt') as f:
        f.write(s + 'endmodule\n')


def base(extra='', off=False, nextfn=False, fn=FN, lp=LP, tail=ASSIGN):
    return FN_HDR + fn + (OFF if off else '') + (NEXTFN if nextfn else '') + lp + extra + tail


# ---------------------------------------------------------------- x: the attack
w('x1_v1x2_n25', base(), k=2, n=25)
w('x2_v1x2_n20', base(), k=2, n=20)
w('x3_v1x3_n25', base(), k=3, n=25)
w('x4_v2x2_n25', base('  localparam bit [N-1:0][15:0] OFFSET_LIST = get_offset_list(SUB_N_LIST);\n',
                      off=True), k=2, n=25)

# ------------------------------------------------------------- z: demand grid
w('z1_unrel_int',      base('  localparam int UNREL = 7;\n'))
w('z2_int_consumer',   base('  localparam int NEXT = SUB_N_LIST[0];\n'))
w('z3_range_consumer', base('  logic [SUB_N_LIST[0]+1:0] wide;\n  assign wide = 0;\n'))
w('z4_nextn_fn',       base('  localparam int NEXT_N = get_next_n(SUB_N_LIST);\n', nextfn=True))
w('z5_gen_consumer',   base('  generate if (SUB_N_LIST[0] > 1) begin : g1\n'
                            '    logic d;\n  end endgenerate\n'))
w('z6_display',        base('  initial $display("%d", SUB_N_LIST[0]);\n'))
w('z7_arr_consumer',   base('  localparam bit [N-1:0][15:0] COPY = SUB_N_LIST;\n'))
w('z8_vec_consumer',   base('  localparam logic [15:0] SMALL = SUB_N_LIST[0];\n'))
w('z9_gen_lp',         base('  generate if (1) begin : g\n'
                            '    localparam int NX = SUB_N_LIST[0];\n'
                            '    logic [NX:0] d;\n  end endgenerate\n'))
w('z10_chain',         base('  localparam bit [N-1:0][15:0] COPY = SUB_N_LIST;\n'
                            '  localparam int NX = COPY[0];\n'))
w('z11_unrel_chain',   base('  localparam int NX = N + 1;\n  logic [NX:0] d;\n'))

# --------------------------------------------------------- y: the brief's list
w('y1_nested', FN_HDR + FN.replace('get_sub_n_list', 'inner') +
  '  function automatic bit [N-1:0][15:0] outer(int n);\n    return inner(n);\n  endfunction\n'
  '  localparam  bit [N-1:0][15:0] SUB_N_LIST  = outer(N);\n' + ASSIGN)
w('y2_recur', FN_HDR +
  '  function automatic int rec(int n);\n    int acc;\n    acc = 0;\n'
  '    if (n > 0) begin\n      acc += 1;\n      acc = acc + rec(n-1);\n    end\n'
  '    return acc;\n  endfunction\n'
  '  localparam int R = rec(N);\n  assign o_result = R[WIDTH-1:0];\nendmodule\n')
w('y3fix_dualctx', base('  bit [N-1:0][15:0] snoop;\n'
                        '  always_comb snoop = get_sub_n_list(N);\n'))
w('y4_multi', FN_HDR + FN.replace('      list_index  += 1;',
                                  '      list_index  += 1;\n      half_n  += 5;') + LP + ASSIGN)
for nm, st in (('y5_sub', '      list_index  -= 1;'), ('y5_mul', '      list_index  *= 2;'),
               ('y5_shl', '      list_index  <<= 1;'), ('y5_mod', '      list_index  %= 7;')):
    w(nm, FN_HDR + FN.replace('      list_index  += 1;', st) + LP + ASSIGN)
w('y6fix_neverconst', FN_HDR + FN + '  bit [N-1:0][15:0] snoop;\n'
  '  always_comb snoop = get_sub_n_list(N);\n'
  '  assign o_result = snoop[0][WIDTH-1:0];\nendmodule\n')
w('y6b_neverconst_int', FN_HDR + FN + '  bit [N-1:0][15:0] snoop;\n'
  '  always_comb snoop = get_sub_n_list(N);\n  localparam int NX = N+1;\n  logic [NX:0] d;\n'
  '  assign o_result = snoop[0][WIDTH-1:0];\nendmodule\n')
w('y7_narrowidx', FN_HDR + FN.replace('    int               list_index;',
                                      '    bit [4:0]         list_index;') + LP + ASSIGN)
w('y8_sized', FN_HDR + FN.replace('list_index  += 1;', "list_index  += 4'd1;") + LP + ASSIGN)
w('y9_paramloop', FN_HDR +
  '  function automatic bit [N-1:0][15:0] f(int n);\n'
  '    bit [N-1:0][15:0] list;\n    int i;\n'
  "    list = '0;\n    i = 0;\n"
  "    while (i < n) begin\n      list[i] = 16'(i);\n      i += 1;\n    end\n"
  '    return list;\n  endfunction\n'
  '  localparam  bit [N-1:0][15:0] SUB_N_LIST  = f(N);\n' + ASSIGN)

PKG_FN = '''  function automatic bit [24:0][15:0] get_sub_n_list(int n);
    bit [24:0][15:0] list;
    int list_index;
    bit [15:0] current_n;
    list = '0;
    list_index = 0;
    current_n = 16'(n);
    while (current_n > 0) begin
      if (current_n >= 4) list[list_index] = 4;
      else                list[list_index] = current_n;
      current_n -= list[list_index];
      list_index += 1;
    end
    return list;
  endfunction
'''
PKG_NEXT = '''  function automatic int get_next_n(bit [24:0][15:0] sub_n_list);
    int next_n;
    next_n = 0;
    for (int i = 0;i < 25;++i) next_n += ((sub_n_list[i] != 0) ? 1 : 0);
    return next_n;
  endfunction
'''
w('ya_pkg', 'package p;\n' + PKG_FN + 'endpackage\n' + FN_HDR +
  '  localparam bit [24:0][15:0] SUB_N_LIST = p::get_sub_n_list(25);\n' + ASSIGN)

# --------------------------------------------- w: the DEMANDED shape perturbed
DEM = base('  localparam int NEXT_N = get_next_n(SUB_N_LIST);\n', nextfn=True)
w('w1_sized_dem', DEM.replace('list_index  += 1;', "list_index  += 4'd1;"))
w('w2_hex_dem',   DEM.replace('list_index  += 1;', "list_index  += 8'h1;"))
w('w3_bin_dem',   DEM.replace('list_index  += 1;', "list_index  += 32'b1;"))
w('w4_narrow_dem', DEM.replace('    int               list_index;',
                               '    bit [4:0]         list_index;'))
w('w5_multi_dem',  DEM.replace('      list_index  += 1;',
                               '      list_index  += 1;\n      half_n  -= 3;'))
w('w6_multi_add_dem', DEM.replace('      list_index  += 1;',
                                  '      list_index  += 1;\n      half_n  += 3;'))
w('w7_dem_x3', DEM, k=3)
w('w8_dem_n2', DEM, k=2, n=2)
w('w9_dem_n4', DEM, k=2, n=4)
PKG_DEM = ('package p;\n' + PKG_FN + PKG_NEXT + 'endpackage\n' + FN_HDR +
           '  localparam bit [24:0][15:0] SUB_N_LIST = p::get_sub_n_list(25);\n'
           '  localparam int NEXT_N = p::get_next_n(SUB_N_LIST);\n'
           '  logic [NEXT_N:0] d;\n' + ASSIGN)
w('wa_pkg_dem', PKG_DEM, k=2)
w('wb_pkg_dem1', PKG_DEM, k=1)
print('cells written')
