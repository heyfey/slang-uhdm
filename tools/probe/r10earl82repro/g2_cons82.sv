// r10earl82 g2 — THE CONSUMER AXIS.  One parameter (`localparam int PI = 8`,
// package home, bare-decimal initialiser) read from every consumer that can
// hold a folded constant.  MEASUREMENT ONLY.
package pk2_82;
  localparam int PI = 8;
endpackage

module leaf2_82 #(parameter int NN = 1) (input logic i, output logic o);
  assign o = i ^ (NN[0]);
endmodule

function automatic logic uf2_82(input int a);
  return a[0];
endfunction

module m2_82 import pk2_82::*; (input logic clk, input logic [63:0] w,
                                output logic [63:0] o);
  typedef struct packed { logic [3:0] a; } mr_t;

  // (a) PACKED range-form bound on a VARIABLE declaration  <-- THE HEAD
  mr_t [PI:0] a_pk;
  // (a2) PACKED range-form bound on a plain logic net
  logic [PI:0] a_net;
  // (a3) PACKED range-form with the parameter on the RIGHT
  logic [15:PI] a_rt;
  // (a4) PACKED range-form on a VAR (not a net)
  logic [PI:0] a_var; always_comb a_var = '0;
  // (b) UNPACKED SIZE-form dimension
  logic [3:0] b_sz [PI];
  // (c) UNPACKED RANGE-form dimension
  logic [3:0] c_rg [PI:0];
  // (d) PACKED range-form inside a TYPEDEF
  typedef logic [PI:0] d_t;
  d_t d_v;
  // (d2) UNPACKED dimension inside a typedef
  typedef logic [3:0] d2_t [PI:0];
  d2_t d2_v;

  logic [63:0] ps, e_op, g_bs, h_rep;
  // (e) PART-SELECT bound in an expression
  assign ps = {57'b0, w[PI:1]};
  // (f) EXPRESSION operand
  assign e_op = w + PI;
  // (g) BIT-SELECT index
  assign g_bs = {63'b0, w[PI]};
  // (h) REPLICATION count
  assign h_rep = {{PI{1'b1}}, 56'b0};
  // (i) High_conn ACTUAL (a bare parameter read at a port)
  logic hc_o;
  leaf2_82 #(.NN(PI)) u_hc (.i(w[PI]), .o(hc_o));
  // (j) USER CALL argument
  logic j_call; assign j_call = uf2_82(PI);
  // (k) CASE item
  logic k_case;
  always_comb begin
    k_case = 1'b0;
    case (w[7:0])
      PI: k_case = 1'b1;
      default: k_case = 1'b0;
    endcase
  end
  // (l) parameter OVERRIDE actual is (i)'s .NN(PI)
  // (m) a CONTINUOUS-ASSIGN rhs bare read
  logic [63:0] m_ca; assign m_ca = PI;
  // (n) an INDEXED part-select base
  assign o = ps ^ e_op ^ g_bs ^ h_rep ^ m_ca ^
             {63'b0, hc_o ^ j_call ^ k_case ^ clk} ^
             {60'b0, a_pk[0].a} ^ {63'b0, a_net[0]} ^ {63'b0, a_rt[15]} ^
             {63'b0, a_var[0]} ^ {60'b0, b_sz[0]} ^ {60'b0, c_rg[0]} ^
             {63'b0, d_v[0]} ^ {60'b0, d2_v[0]} ^ {57'b0, w[PI +: 3]};
endmodule
