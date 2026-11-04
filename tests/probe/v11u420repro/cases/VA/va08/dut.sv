// § arrayBcastConcatActual420
module child(input logic [3:0] a);
endmodule
module top;
  logic x, y;
  child c[1:0] (.a({{x, y}, {y, x}}));
endmodule
