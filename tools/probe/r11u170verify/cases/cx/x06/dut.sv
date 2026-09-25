// § sizeCastCaLitMask158 § defNetTypeParamPackedVec160
module sub #(parameter type T = logic [1:0]) (input logic clk, output logic [7:0] p, output logic [7:0] r, output logic [3:0] o);
  T [1:0] q;
  always_ff @(posedge clk) q <= '0;
  assign o = q;
  assign p = $bits(T)'(7);
  assign r = T'(7);
endmodule
module top (input logic clk, output logic [7:0] p, output logic [7:0] r, output logic [3:0] o); sub u(.clk(clk), .p(p), .r(r), .o(o)); endmodule
