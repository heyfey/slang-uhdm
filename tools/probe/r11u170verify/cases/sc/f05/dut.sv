// § sizeCastNamedWidthNoCast158v
package pk; localparam int W = 2; endpackage
module dut (output logic [7:0] p, output logic [7:0] q);
  localparam int W = 2;
  assign p = (W)'(7);
  assign q = (pk::W)'(-1);
endmodule
