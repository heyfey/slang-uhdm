// § arrayBcastConcatActual420
module child(input logic [1:0] a);
endmodule
module top;
  localparam logic P = 1'b1;
  logic x;
  child c[1:0] (.a({P, x}));
endmodule
