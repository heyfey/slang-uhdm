// § genNdaUnsizedFreshLhs438
module sub #(parameter M = 1) (input [15:0] b, output y);
  if (M == 1) begin : g
    wire w = b['h2];
    assign y = w;
  end else begin : h
    wire w = b['h3];
    assign y = w;
  end
endmodule
module top(input [15:0] b, output y, z);
  sub #(.M(1)) u(.b(b), .y(y));
  sub #(.M(0)) v(.b(b), .y(z));
endmodule
