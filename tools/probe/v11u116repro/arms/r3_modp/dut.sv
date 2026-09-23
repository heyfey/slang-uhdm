package pk;
  typedef enum logic [6:0] { OP_SYS = 7'h73, OP_LUI = 7'h37 } op_e;
  parameter logic [31:0] P_CAT = { 12'b0, 13'b0, {OP_SYS} };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
  parameter int unsigned P_C4 = {28'd0, 4'd3};
  parameter logic [6:0] P_LIT = 7'h73;
  parameter int P_INT = 5;
  parameter bit [3:0] P_BIT = 4'b1010;
  parameter P_UNT = 32'h73;
  parameter int unsigned P_UNS = 'h73;
  parameter logic [6:0] P_PAR = P_LIT;
endpackage
module dut import pk::*; #(parameter logic [6:0] M = 7'h11) (input logic [31:0] x, output logic [3:0] y);
  localparam int L = 3;
  always_comb begin
    y = 0;
    case (x[6:0])
      M: y = 1;
      L: y = 2;
      P_LIT: y = 3;
      default: y = 9;
    endcase
  end
endmodule
