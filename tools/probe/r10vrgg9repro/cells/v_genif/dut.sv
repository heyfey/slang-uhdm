module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  if (1) begin : g
    assign arr[0] = (P) ? 42 : 7;
  end
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
