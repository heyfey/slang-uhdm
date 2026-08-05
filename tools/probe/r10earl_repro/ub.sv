// r10earl9 witness B — the FULL argument-shape matrix of the def-view
// sys-call argument emitter (TypeEmit emitSyntaxExpr, the raw-text ref_obj
// fallback).  ua.sv proved a BINARY argument and a plain LITERAL argument are
// both wrong; this pins down every other shape so the fix is not widened past
// what golden actually does.
package ubp;
  parameter int PW = 12;
  typedef struct packed { logic [7:0] a; logic [3:0] b; } st_t;
endpackage

module ub #(
  parameter int W = 32,
  parameter int N = 10
) (
  input  logic clk_i,
  output logic o
);
  typedef struct packed { logic [15:0] x; logic [1:0] y; } my_t;
  my_t                   mv;
  logic [W-1:0]          vec;
  logic [3:0][7:0]       arr;

  // ---- $clog2 argument shapes
  logic [$clog2(W)-1:0]            r_id;      // identifier          (control)
  logic [$clog2(64)-1:0]           r_lit;     // integer literal
  logic [$clog2(N+1)-1:0]          r_bin;     // binary op
  logic [$clog2((N+1))-1:0]        r_par;     // parenthesised binary
  logic [$clog2(-N)-1:0]           r_un;      // unary op
  logic [$clog2(N > 4 ? N : 4)-1:0] r_tern;   // conditional
  logic [$clog2(ubp::PW)-1:0]      r_scp;     // scoped package param
  logic [$clog2(ubp::PW+1)-1:0]    r_scpb;    // scoped param in a binary
  logic [$clog2({4'd3, 4'd2})-1:0] r_cat;     // concatenation (already routed)
  logic [$clog2(2**N)-1:0]         r_pow;     // power op

  // ---- $bits argument shapes
  logic [$bits(my_t)-1:0]          b_type;    // local TYPE name (control)
  logic [$bits(ubp::st_t)-1:0]     b_ptype;   // package TYPE name
  logic [$bits(mv)-1:0]            b_var;     // variable name (control)
  logic [$bits(mv.x)-1:0]          b_memb;    // member access (routed: '.')
  logic [$bits(arr[1])-1:0]        b_sel;     // element select
  logic [$bits(vec[3:0])-1:0]      b_rsel;    // range select

  assign o = clk_i ^ ^{r_id, r_lit, r_bin, r_par, r_un, r_tern, r_scp,
                       r_scpb, r_cat, r_pow, b_type, b_ptype, b_var,
                       b_memb, b_sel, b_rsel} ^ ^mv ^ ^vec ^ ^arr;
endmodule
