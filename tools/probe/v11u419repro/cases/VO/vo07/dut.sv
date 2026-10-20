// § implicitPortParamListedFirst419
module m #(parameter A = 1, int B = 2) (input [A-1:0] x, output [7:0] y);
  assign y = A + B;
endmodule
module top(input x, output [7:0] y);
  for (genvar g = 0; g < 2; g++) begin : gg
    m #(.B(g)) u(x, );
  end
  m w(x, y);
endmodule
