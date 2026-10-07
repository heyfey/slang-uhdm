// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int A = -3;
  localparam logic [7:0] C = ~8'h0F;
endpackage
module dut(output int o);
  import pk::*;
  assign o = A + C;
endmodule
