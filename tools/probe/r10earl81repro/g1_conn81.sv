// r10earl81 arm g1 — the head's shape (tlul_socket_1n.sv:215 `.tl_h_i(tl_u_o[N])`)
// minimised: a PORT High_conn SELECT whose index/bound names each candidate
// REFERENT, in each HOME, with the neighbouring SLOTS and the BODY-POSITION
// twins alongside as controls.  MEASUREMENT ONLY.
package p81;
  parameter  int unsigned PP = 3;
  localparam int unsigned PL = 1;
endpackage

module leaf81 (
  input  logic       ib,
  input  logic [3:0] iv,
  output logic       o
);
  assign o = ib ^ (^iv);
endmodule

module mid81 #(
  parameter int unsigned N = 4,   // OVERRIDDEN at every instantiation
  parameter int unsigned M = 5,   // never overridden
  parameter bit [3:0]    H = 4'h2 // overridden with a BASED HEX actual
) (
  input  logic [15:0] w,
  output logic [23:0] y
);
  import p81::*;
  localparam int unsigned L = 2;
  genvar gi;

  // ---- MODULE-BODY home, port High_conn, bit-select INDEX -----------------
  leaf81 uA (.ib(w[N]),        .iv(w[3:0]), .o(y[0]));  // overridden mod param
  leaf81 uB (.ib(w[M]),        .iv(w[3:0]), .o(y[1]));  // NON-overridden param
  leaf81 uC (.ib(w[L]),        .iv(w[3:0]), .o(y[2]));  // module localparam
  leaf81 uD (.ib(w[PP]),       .iv(w[3:0]), .o(y[3]));  // pkg param, imported
  leaf81 uE (.ib(w[p81::PL]),  .iv(w[3:0]), .o(y[4]));  // pkg localparam, qual
  leaf81 uF (.ib(w[N+1]),      .iv(w[3:0]), .o(y[5]));  // EXPRESSION over N
  leaf81 uG (.ib(w[H]),        .iv(w[3:0]), .o(y[6]));  // based-hex override
  leaf81 uH (.ib(w[3]),        .iv(w[3:0]), .o(y[7]));  // literal (control)

  // ---- MODULE-BODY home, port High_conn, the NEIGHBOURING SLOTS ----------
  leaf81 uI (.ib(w[0]), .iv(w[N+3:N]),  .o(y[8]));   // part-select BOUNDS
  leaf81 uJ (.ib(w[0]), .iv(w[N +: 4]), .o(y[9]));   // ips base / width
  leaf81 uK (.ib(w[0]), .iv(w[L+3:L]),  .o(y[10]));  // localparam bounds
  leaf81 uL (.ib(w[0]), .iv(w[PP +: 4]),.o(y[11]));  // pkg-param ips base

  // ---- BODY-POSITION TWINS (the control: same index, other home) ---------
  assign y[12] = w[N];              // module-body cont_assign
  assign y[13] = w[L];
  always_comb y[14] = w[N];         // procedural
  localparam int unsigned PI = N;   // param-init

  // ---- GEN-SCOPE homes ----------------------------------------------------
  for (gi = 0; gi < 2; gi++) begin : gblk
    localparam int unsigned GL = gi + 1;
    leaf81 uGa (.ib(w[GL]),  .iv(w[3:0]), .o(y[15+gi]));   // own-block localparam
    leaf81 uGb (.ib(w[N]),   .iv(w[3:0]), .o(y[17+gi]));   // module param
    leaf81 uGc (.ib(w[gi]),  .iv(w[3:0]), .o(y[19+gi]));   // genvar
    leaf81 uGd (.ib(w[PP]),  .iv(w[3:0]), .o(y[21+gi]));   // pkg param
    assign y[23] = w[N] & w[gi];                            // gen-scope CA twin
  end

  if (N > 1) begin : gif
    leaf81 uIf (.ib(w[N]), .iv(w[N+3:N]), .o());            // gen-if home
  end
endmodule

module top81 (input logic [15:0] w, output logic [23:0] y0, y1, y2);
  mid81 #(.N(2), .H(4'h6)) i0 (.w(w), .y(y0));
  mid81 #(.N(3), .H(4'h6)) i1 (.w(w), .y(y1));
  mid81 #(.N(4), .H(4'h6)) i2 (.w(w), .y(y2));
endmodule
