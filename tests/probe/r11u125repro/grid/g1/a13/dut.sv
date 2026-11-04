// § genvarParamFile125
module sub #(parameter N = 2) (output [N-1:0] o);
  for (genvar i = 0; i < N; i++) begin : g
    assign o[i] = 1'b1;
  end
endmodule
module top(output [5:0] o);
  sub #(2) u1(o[1:0]);
  sub #(4) u2(o[5:2]);
endmodule
