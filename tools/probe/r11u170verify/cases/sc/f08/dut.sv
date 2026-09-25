// § sizeCastCaSignedSize158
package pk; localparam int V = 7; localparam int unsigned U = 7; localparam int N = -1; endpackage
module dut (output logic [3:0] p, output logic [3:0] q, output logic [7:0] r);
  assign p = 2'(pk::V);
  assign q = 2'(pk::U);
  assign r = 3'(pk::N);
endmodule
