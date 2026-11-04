// § sizeCastCaSignedSize158
package pk; localparam int V = 7; endpackage
module dut (output logic [3:0] p, output logic [7:0] r);
  localparam int L = pk::V;
  assign p = 2'(L);
  assign r = 3'(pk::V);
endmodule
