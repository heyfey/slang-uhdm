// § sizeCastCaSignedSize158
package pk; localparam int V = 7; localparam int N = -1; endpackage
module dut (output logic [3:0] p, output logic [7:0] r);
  import pk::*;
  assign p = 2'(V);
  assign r = 3'(N);
endmodule
