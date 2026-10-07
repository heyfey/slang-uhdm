// § pkgElabUnaryFoldOpSpan274
package pa;
  parameter int A = -3;
endpackage
package pb;
  import pa::*;
  parameter int B = -A;
  parameter int C = ~pa::A;
endpackage
module dut(output int o, output int c);
  import pb::*;
  assign o = B; assign c = C;
endmodule
