// § arrayBcastConcatActual420
module child(input logic [1:0] a);
endmodule
module top;
  logic x;
  child c[1:0] (.a({1'b0, x}));
endmodule
