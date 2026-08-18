module leaf(input logic [7:0] i);
endmodule
module m #(parameter bit P = 0)();
  logic sig;
  leaf u_l(.i((P) ? 8'd42 : 8'd7));
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
