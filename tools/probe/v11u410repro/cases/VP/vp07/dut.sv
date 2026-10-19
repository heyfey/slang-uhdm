// § parenCastNameUnsupTs410
module top #(parameter W = 4, parameter type T = logic [3:0]) (input logic [7:0] x, output logic [7:0] y, z);
  typedef logic [2:0] t3;
  if (W > 1) begin : g
    assign y = (t3)'(x);
    assign z = (T)'(x);
  end
endmodule
