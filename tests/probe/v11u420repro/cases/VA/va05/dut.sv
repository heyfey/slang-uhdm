// § arrayBcastConcatActual420
module child(input logic [1:0] a);
endmodule
module top;
  logic [3:0] v;
  child c[0:1] (.a({v[3:2]}));
endmodule
