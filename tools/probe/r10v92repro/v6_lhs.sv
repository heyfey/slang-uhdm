// v92 adversarial arm 6 — Lhs shapes and non-cont_assign homes.
// plainLhs is `stripImplicitConv(ae.left()).kind == NamedValue`; the Surelog
// gate is `lhs->UhdmType()==uhdmref_obj` AND `bindVariable(...)` non-null.
// Also: procedural / initial / always / function-body ternaries, a net-decl
// assign, a port High_conn, and a parameter initializer.
module v6_sink (input logic [3:0] a, input logic [3:0] b, output logic [3:0] o);
  assign o = a ^ b;
endmodule

module v6_lhs #(parameter bit EN = 1, parameter int N = 3) (
    input  logic [7:0] k,
    input  logic       clk,
    output logic [3:0] y_plain,
    output logic [3:0] y_netdecl,
    output logic [3:0] y_proc,
    output logic [3:0] y_always,
    output logic [3:0] y_init,
    output logic [3:0] y_func,
    output logic [3:0] y_hc,
    output logic [3:0] y_arrlhs
);
  logic [3:0] arr [0:1];
  // whole-signal Lhs -> the law's own shape
  assign y_plain   = EN ? (k[5] ^ k[1]) : 4'h0;
  // net-decl-assign
  wire  [3:0] w_nd = EN ? (k[5] ^ k[2]) : 4'h0;
  assign y_netdecl = w_nd;
  // procedural continuous assign
  always_comb y_proc = EN ? (k[5] ^ k[3]) : 4'h0;
  always @(posedge clk) y_always <= EN ? (k[4] ^ k[1]) : 4'h0;
  initial y_init = EN ? (k[4] ^ k[2]) : 4'h0;
  function automatic logic [3:0] f6(input logic [7:0] kk);
    return EN ? (kk[4] ^ kk[3]) : 4'h0;
  endfunction
  assign y_func = f6(k);
  // port high_conn carrying a ternary
  v6_sink u_s (.a(EN ? (k[3] ^ k[1]) : 4'h0), .b(4'h1), .o(y_hc));
  // an unpacked-array element Lhs
  assign arr[0]  = EN ? (k[3] ^ k[2]) : 4'h0;
  assign arr[1]  = 4'h0;
  assign y_arrlhs = arr[0];
  // a parameter initializer carrying a ternary
  localparam logic [3:0] LP = EN ? 4'h5 : 4'h0;
  wire [3:0] unused_lp = LP;
endmodule
