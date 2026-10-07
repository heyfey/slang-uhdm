// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int A = -3;
endpackage
package pk2;
  import pk::*;
  parameter int B = -A;
  parameter int C = -pk::A;
endpackage
module dut(output int o);
  assign o = 0;
endmodule
