package pk;
  typedef enum logic [6:0] { OP_SYS = 7'h73, OP_LUI = 7'h37 } op_e;
  typedef logic [31:0] w_t;
  parameter logic [31:0] P_CAT = { 12'b0, 13'b0, {OP_SYS} };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
  parameter logic [31:0] P_NOT = ~{ 25'h0, 7'h37 };
  parameter logic [31:0] P_LIT = 32'h00000073;
  parameter int P_INT = 115;
  parameter w_t P_TD = 32'h37;
  parameter P_UNT = 32'h73;
endpackage
module top import pk::*; (input logic [31:0] x, output logic [3:0] y, output logic [31:0] z, output logic [31:0] w, output logic u);
  if (1) begin : g
    always_comb begin
      z = x & P_CAT;
      if (x == P_REP) y = 4'd1; else y = 4'd0;
    end
    assign w = P_NOT;
  end
endmodule
