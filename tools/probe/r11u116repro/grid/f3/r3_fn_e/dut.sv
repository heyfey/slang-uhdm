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
module top import pk::P_LIT, pk::P_INT, pk::P_TD, pk::P_UNT, pk::P_CAT; (input logic [31:0] x, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [31:0] a);
    logic [3:0] y;
    case (a)
      P_LIT: y = 4'd1;
      P_INT: y = 4'd2;
      P_TD: y = 4'd3;
      P_UNT: y = 4'd4;
      P_CAT: y = 4'd5;
      default: y = 4'd0;
    endcase
    return y;
  endfunction
  assign y = f(x);
endmodule
