// § parenCastNameUnsupTs410
module sub #(parameter W = 4) (input logic [7:0] x, output logic [7:0] y);
  if (W > 1) begin : g
    assign y = (W)'(x) + W'(x);
  end
endmodule
module top (input logic [7:0] x, output logic [7:0] y, z);
  sub #(3) a(.x(x), .y(y));
  sub b(.x(x), .y(z));
endmodule
