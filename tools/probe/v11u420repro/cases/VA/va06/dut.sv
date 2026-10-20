// § arrayBcastConcatActual420
module child(input logic [1:0] a);
endmodule
module top;
  logic x, y;
  if (1) begin : g
    child c[1:0] (.a({x, y}));
  end
endmodule
