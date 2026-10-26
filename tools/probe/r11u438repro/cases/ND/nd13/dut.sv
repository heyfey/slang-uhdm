// § genNdaUnsizedFreshLhs438 (control: a parameter-only initializer)
module sub #(parameter [15:0] P = 16'h1234) (output y);
  if (1) begin : g
    wire w = P['hA];
    assign y = w;
  end
endmodule
module top(output y);
  sub u(.y(y));
endmodule
