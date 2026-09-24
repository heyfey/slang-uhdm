// explicit import of one param, case item
package pk;
  typedef enum logic [6:0] { OP_SYS = 7'h73, OP_LUI = 7'h37 } op_e;
  parameter logic [31:0] P_CAT  = { 12'b000000000000, 13'b0, {OP_SYS} };
  parameter logic [31:0] P_LIT  = 32'h00000073;
  parameter logic [31:0] P_LCAT = { 12'b000000000001, 13'b0, 7'h73 };
  parameter logic [31:0] P_WILD = { 25'h?, {OP_LUI} };
  localparam logic [31:0] L_CAT = { 25'h0, {OP_LUI} };
  parameter int P_INT = 115;
endpackage
module top (input logic [31:0] x, output logic [3:0] y);
  import pk::P_CAT;
  import pk::P_LIT;
  always_comb begin
    y = 4'd0;
    case (x)
      P_CAT: y = 4'd1;
      P_LIT: y = 4'd2;
      default: y = 4'd7;
    endcase
  end
endmodule
