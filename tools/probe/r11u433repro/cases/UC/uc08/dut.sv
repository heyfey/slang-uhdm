// § connOpUnitParamFold433
localparam OP_A = 5, OP_B = 6;
module child(input a, input [7:0] b, output y);
  assign y = a;
endmodule
module top(input [4:0] oper, output y0, y1);
  for (genvar i = 0; i < 2; i++) begin: g
    child c(.a((oper != OP_B)), .b(oper + OP_A), .y());
  end
  child d(.a(oper == OP_A + 1), .b({OP_A}), .y(y1));
endmodule
