// § sizeCastNamedWidthNoCast158v
package pk; typedef logic [2:0] t3; endpackage
module dut (output logic [7:0] p);
  assign p = pk::t3'(15);
endmodule
