// § typedParamXzLitSize407
module top(output int o, output int o2);
  localparam int la = 2'bz0;
  parameter int ma = 1'bx;
  if (1) begin : g
    localparam int gl = 3'bx01;
    assign o2 = gl;
  end
  assign o = la + ma;
endmodule
