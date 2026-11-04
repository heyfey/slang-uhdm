// § connOpUnitParamFold433
localparam OP_A = 5, OP_B = 6;
module child(input a, output y);
  assign y = a;
endmodule
module top(input [3:0] op, output y);
  child c(.a((op != OP_B)), .y(y));
endmodule
