module m #(parameter bit P = 0)();
  logic [7:0] arr[4];
  for (genvar i = 0; i < 2; i++) begin : g
    assign arr[i] = (P) ? 42 : 7;
  end
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
