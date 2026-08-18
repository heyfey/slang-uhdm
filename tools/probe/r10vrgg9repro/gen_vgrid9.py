import os
ROOT='/tmp/vrgg9_cells'
C={}
def add(n,s): C[n]=s
def mod(body, params='parameter bit P = 0', ports='', extra=''):
    return f"""module m #(
  {params}
)({ports});
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
{extra}
{body}
endmodule
"""
def top(i): return "module top;\n"+i+"endmodule\n"
ONE = "  m #(.P(0)) u_a();\n"
ONE1= "  m #(.P(1)) u_a();\n"

# ---- A. UNTAKEN-ARM OPERAND SHAPES (the whitelist's "passes unchecked" claims)
# taken arm is a CONSTANT in every one of these; only the UNTAKEN arm varies.
add('v_untk_op',     mod("  assign arr[0] = (P) ? 42 : (sig & 1'b1);\n") + top(ONE1))
add('v_untk_concat', mod("  assign arr[0] = (P) ? 42 : {sig,sig};\n") + top(ONE1))
add('v_untk_repl',   mod("  assign arr[0] = (P) ? 42 : {2{sig}};\n") + top(ONE1))
add('v_untk_bitsel', mod("  assign arr[0] = (P) ? 42 : vec[1];\n") + top(ONE1))
add('v_untk_partsel',mod("  assign arr[0] = (P) ? 42 : vec[3:0];\n") + top(ONE1))
add('v_untk_idxpart',mod("  assign arr[0] = (P) ? 42 : vec[1 +: 4];\n") + top(ONE1))
add('v_untk_var',    mod("  assign arr[0] = (P) ? 42 : vr;\n", extra="  logic [7:0] vr;\n") + top(ONE1))
add('v_untk_arrsel', mod("  assign arr[0] = (P) ? 42 : arr[1];\n") + top(ONE1))
add('v_untk_syscall',mod("  assign arr[0] = (P) ? 42 : $bits(vec);\n") + top(ONE1))
add('v_untk_hier',   mod("  assign arr[0] = (P) ? 42 : top.gsig;\n") + "module top;\n  logic gsig;\n" + ONE1 + "endmodule\n")
add('v_untk_struct', """module m #(
  parameter bit P = 0
)();
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  st_t st;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : st.a;
endmodule
""" + top(ONE1))
add('v_untk_ifmem', """interface bif;
  logic [7:0] d;
  modport mst (input d);
endinterface
module m #(parameter bit P = 0)(bif.mst b);
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : b.d;
endmodule
module top;
  bif bi();
  m #(.P(1)) u_a(bi);
endmodule
""")
# ---- B. TAKEN-ARM shapes we refuse
add('v_takn_op_net', mod("  assign arr[0] = (P) ? (sig & 1'b1) : 42;\n") + top(ONE1))
add('v_takn_bitsel', mod("  assign arr[0] = (P) ? vec[1] : 42;\n") + top(ONE1))
add('v_takn_partsel',mod("  assign arr[0] = (P) ? vec[3:0] : 42;\n") + top(ONE1))
add('v_takn_syscall',mod("  assign arr[0] = (P) ? $bits(vec) : 42;\n") + top(ONE1))
add('v_takn_negsz',  mod("  assign arr[0] = (P) ? -4'd1 : 42;\n") + top(ONE1))
add('v_takn_real',   mod("  assign arr[0] = (P) ? 1.5 : 42;\n") + top(ONE1))
add('v_takn_64exact',mod("  assign arr[0] = (P) ? 64'hFFFFFFFFFFFFFFFF : 42;\n") + top(ONE1))
add('v_takn_65',     mod("  assign arr[0] = (P) ? 65'h1FFFFFFFFFFFFFFFF : 42;\n") + top(ONE1))
add('v_takn_xzparam',mod("  assign arr[0] = (P) ? XZ : 42;\n", extra="  localparam logic [3:0] XZ = 4'b10xz;\n") + top(ONE1))
add('v_takn_hierpar',mod("  assign arr[0] = (P) ? top.u_b.P : 42;\n") + "module top;\n  m #(.P(1)) u_a();\n  m #(.P(1)) u_b();\nendmodule\n")
# ---- C. PREDICATE provenance / shape
add('v_pred_xz',     mod("  assign arr[0] = (PX) ? 42 : 7;\n", extra="  localparam logic PX = 1'bx;\n") + top(ONE))
add('v_pred_z',      mod("  assign arr[0] = (PZ) ? 42 : 7;\n", extra="  localparam logic PZ = 1'bz;\n") + top(ONE))
add('v_pred_ne',     mod("  assign arr[0] = (P != 1'b1) ? 42 : 7;\n") + top(ONE))
add('v_pred_lt',     mod("  assign arr[0] = (Q < 3) ? 42 : 7;\n", 'parameter int Q = 1') + top("  m #(.Q(5)) u_a();\n"))
add('v_pred_shift',  mod("  assign arr[0] = (Q >> 1) ? 42 : 7;\n", 'parameter int Q = 1') + top("  m #(.Q(1)) u_a();\n"))
add('v_pred_tern',   mod("  assign arr[0] = ((P) ? 1'b0 : 1'b1) ? 42 : 7;\n") + top(ONE))
add('v_pred_real',   mod("  assign arr[0] = (R > 0.0) ? 42 : 7;\n", 'parameter real R = 1.0') + top("  m u_a();\n"))
add('v_pred_str',    mod("  assign arr[0] = (S == \"a\") ? 42 : 7;\n", 'parameter string S = \"a\"') + top("  m u_a();\n"))
add('v_pred_defpar', mod("  assign arr[0] = (P) ? 42 : 7;\n", 'parameter bit P = 1') + "module top;\n  m u_a();\n  defparam u_a.P = 0;\nendmodule\n")
add('v_pred_specp',  mod("  assign arr[0] = (SP) ? 42 : 7;\n", extra="  specparam SP = 1;\n") + top(ONE))
add('v_pred_bigsel', mod("  assign arr[0] = (Q[0]) ? 42 : 7;\n", 'parameter logic [3:0] Q = 4\'b0001') + top("  m u_a();\n"))
add('v_pred_cast',   mod("  assign arr[0] = (int'(P)) ? 42 : 7;\n") + top(ONE1))
add('v_pred_func',   mod("  assign arr[0] = (fp(1)) ? 42 : 7;\n", extra="  function automatic bit fp(bit x); return x; endfunction\n") + top(ONE))
add('v_pred_pkgfn',  """package pk;
  function automatic bit g(); return 1'b1; endfunction
endpackage
module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (pk::g()) ? 42 : 7;
endmodule
""" + top(ONE))
# ---- D. NESTING / recursion (rc must never be 139)
def deep(n):
    e = "42"
    for i in range(n):
        e = f"(P) ? {e} : {i}"
    return e
add('v_deep8',  mod(f"  assign arr[0] = {deep(8)};\n") + top(ONE1))
add('v_deep40', mod(f"  assign arr[0] = {deep(40)};\n") + top(ONE1))
add('v_recfn',  mod("  assign arr[0] = (P) ? fr(3) : 7;\n", extra="  function automatic int fr(int n); if (n<=0) return 1; return n*fr(n-1); endfunction\n") + top(ONE1))
add('v_selfpar',mod("  assign arr[0] = (P) ? A : 7;\n", extra="  localparam int A = 4;\n  localparam int B = A + 1;\n") + top(ONE1))
# ---- E. CONTEXTS
add('v_program', """program pr #(parameter bit P = 0)();
  logic [7:0] arr[2];
  initial arr[0] = (P) ? 42 : 7;
endprogram
module top;
  pr #(.P(1)) u_a();
endmodule
""")
add('v_genif', """module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  if (1) begin : g
    assign arr[0] = (P) ? 42 : 7;
  end
endmodule
""" + top(ONE1))
add('v_genfor', """module m #(parameter bit P = 0)();
  logic [7:0] arr[4];
  for (genvar i = 0; i < 2; i++) begin : g
    assign arr[i] = (P) ? 42 : 7;
  end
endmodule
""" + top(ONE1))
add('v_nestmod', """module inner #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : 7;
endmodule
module m #(parameter bit P = 0)();
  inner #(.P(P)) u_i();
endmodule
""" + top(ONE1))
add('v_commalist', mod("  assign arr[0] = (P) ? 42 : 7, arr[1] = (P) ? 9 : 3;\n") + top(ONE1))
add('v_lhsconcat', mod("  assign {vec[1],vec[0]} = (P) ? 2'b11 : 2'b00;\n") + top(ONE1))
add('v_lhspart',   mod("  assign vec[3:0] = (P) ? 4'hA : 4'h5;\n") + top(ONE1))
add('v_lhsidxpart',mod("  assign vec[0 +: 4] = (P) ? 4'hA : 4'h5;\n") + top(ONE1))
add('v_3inst_mix', mod("  assign arr[0] = (P) ? 42 : 7;\n", 'parameter bit P = 1') +
    top("  m #(.P(0)) u_a();\n  m #(.P(1)) u_b();\n  m #(.P(0)) u_c();\n"))
add('v_iface_ca', """interface bif #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : 7;
endinterface
module top;
  bif #(.P(1)) bi();
endmodule
""")
add('v_portconn', """module leaf(input logic [7:0] i);
endmodule
module m #(parameter bit P = 0)();
  logic sig;
  leaf u_l(.i((P) ? 8'd42 : 8'd7));
endmodule
""" + top(ONE1))
os.makedirs(ROOT, exist_ok=True)
for n,s in C.items():
    d=os.path.join(ROOT,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(s)
print(len(C),"cells")
