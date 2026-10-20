// § arrayBcastConcatActual420
module child(input logic [1:0] a);
endmodule
module top;
  logic [3:0] v;
  child c[1:0] (.a({v[1], v[0]}));
endmodule
