// r10earl83 arm 3 — THE LAW ARM.  The three CORPUS shapes (a size cast whose
// width is a PARAMETER, over a plain / hex / binary literal) reproduced
// minimally, plus the width and base cells the law's model must answer, plus
// the same cast in every FENCED position.  MEASUREMENT ONLY.
package q83;
  parameter int PING_CNT_DW = 24;
  parameter int WakeUpPeris = 16;
endpackage

module k83 #(parameter int BusWidth = 32) (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule

module w83 (input logic [95:0] a, output logic [95:0] y);
  assign y = ~a;
endmodule

function automatic logic [63:0] uf83(input logic [63:0] q);
  return q ^ 64'h5a;
endfunction

module g3_law83;
  import q83::*;
  localparam int BusWidth = 32;
  logic [63:0] r [0:29];
  logic [95:0] rw [0:3];
  logic [63:0] acc;
  logic [95:0] wide;

  // ---- THE THREE CORPUS SHAPES ---------------------------------------
  k83 c0 (.a(BusWidth'(0)),                 .y(r[0]));   // flash_ctrl.sv:137
  k83 c1 (.a({40'd0, q83::PING_CNT_DW'(24'hFFFFFF)}), .y(r[1])); // alert_handler.sv:87
  k83 c2 (.a({48'd0, q83::WakeUpPeris'(1'b1)}),  .y(r[2]));   // pwrmgr_pkg.sv:156

  // ---- THE SAME THREE, THREE INSTANCES EACH ---------------------------
  k83 c3 (.a(BusWidth'(0)), .y(r[3]));
  k83 c4 (.a(BusWidth'(0)), .y(r[4]));
  k83 #(.BusWidth(16)) c5 (.a(BusWidth'(0)), .y(r[5]));

  // ---- WIDTH cells ----------------------------------------------------
  k83 w00 (.a(1'(1)),            .y(r[6]));
  k83 w01 (.a(4'(9)),            .y(r[7]));
  k83 w02 (.a(8'(300)),          .y(r[8]));
  k83 w03 (.a(32'(64'hDEADBEEF)),.y(r[9]));
  k83 w04 (.a(63'(64'hFFFFFFFFFFFFFFFF)), .y(r[10]));
  k83 w05 (.a(64'(64'hFFFFFFFFFFFFFFFF)), .y(r[11]));
  w83 w06 (.a(96'(64'hFFFFFFFFFFFFFFFF)), .y(rw[0]));
  k83 w07 (.a(integer'(0)),      .y(r[12]));

  // ---- BASE cells (the operand encoding) ------------------------------
  k83 b00 (.a(32'(9)),      .y(r[13]));   // plain decimal
  k83 b01 (.a(32'(8'd9)),   .y(r[14]));   // based DECIMAL, unsigned
  k83 b02 (.a(32'(8'sd9)),  .y(r[15]));   // based DECIMAL, SIGNED
  k83 b03 (.a(32'(4'hb)),   .y(r[16]));   // hex
  k83 b04 (.a(32'(4'o7)),   .y(r[17]));   // octal
  k83 b05 (.a(32'(4'b1010)),.y(r[18]));   // binary
  k83 b06 (.a(32'(4'sh3)),  .y(r[19]));   // SIGNED hex
  k83 b07 (.a(32'(1'bx)),   .y(r[20]));   // X
  k83 b08 (.a(32'(BusWidth)), .y(r[21])); // a PARAMETER operand
  k83 b09 (.a(32'(1 + 2)),  .y(r[22]));   // an EXPRESSION operand
  k83 b10 (.a(32'(acc)),    .y(r[23]));   // a NET operand

  // ---- FENCED positions, same cast ------------------------------------
  k83 f00 (.a(uf83(32'(9))),               .y(r[24])); // user call argument
  k83 f01 (.a({48'd0, acc[32'(19):32'(4)]}), .y(r[25])); // part-select bound
  assign r[26] = 32'(9);                                // cont_assign Rhs
  always_comb r[27] = 32'(9);                           // body statement
  k83 #(.BusWidth(32'(9))) f02 (.a(64'd0), .y(r[28]));  // instance param actual
  localparam int F03 = 32'(9);                          // param init
  for (genvar gj = 0; gj < 2; gj++) begin : gb83
    k83 f04 (.a(32'(9)), .y(r[29]));                    // gen-scope High_conn
  end

  always_comb begin
    acc = 64'(F03);
    for (int i = 0; i < 30; i++) acc = acc ^ r[i];
  end
  assign wide = rw[0];
endmodule
