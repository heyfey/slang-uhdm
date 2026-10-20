// § arrayBcastConcatActual420
module child(input logic [1:0] a);
endmodule
module top;
  logic x, y;
  child c[1:0] ({x, y});
endmodule
