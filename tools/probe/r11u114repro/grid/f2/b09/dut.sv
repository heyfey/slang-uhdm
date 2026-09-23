// case items in always_ff with a begin block, non-unique
package pk;
  typedef enum logic [6:0] { OP_SYS = 7'h73, OP_LUI = 7'h37 } op_e;
  parameter logic [31:0] P_CAT  = { 12'b000000000000, 13'b0, {OP_SYS} };
  parameter logic [31:0] P_LIT  = 32'h00000073;
  parameter logic [31:0] P_LCAT = { 12'b000000000001, 13'b0, 7'h73 };
  parameter logic [31:0] P_WILD = { 25'h?, {OP_LUI} };
  localparam logic [31:0] L_CAT = { 25'h0, {OP_LUI} };
  parameter int P_INT = 115;
endpackage
module top import pk::*; (input logic clk, input logic [31:0] x, output logic [3:0] y);
  always_ff @(posedge clk) begin
    case (x)
      P_CAT: y <= 4'd1;
      P_LCAT: y <= 4'd3;
      default: y <= 4'd7;
    endcase
  end
endmodule
