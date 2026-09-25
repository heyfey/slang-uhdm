// § psBoundBareRefByBase145
package pk;
  localparam int W = 8;
  localparam int L = 4;
endpackage
module dut(input logic [31:0] a, output logic [4:0] o);
  import pk::*;
  assign o = a[W:L];
endmodule
