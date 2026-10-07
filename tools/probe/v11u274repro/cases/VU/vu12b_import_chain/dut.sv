// § pkgElabUnaryFoldOpSpan274
package pa;
  parameter int A = -3;
endpackage
package pb;
  import pa::*;
  parameter int B = -A;
  parameter int C = ~pa::A;
endpackage
module dut(output int o); assign o = 0; endmodule
