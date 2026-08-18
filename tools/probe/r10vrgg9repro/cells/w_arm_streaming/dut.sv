module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  logic [7:0] s;
  assign arr[0] = (P) ? 42 : {<<{s}};
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
