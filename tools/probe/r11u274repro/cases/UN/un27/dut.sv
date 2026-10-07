// § pkgElabUnaryFoldOpSpan274
interface ifc;
  localparam int A = -3;
endinterface
package pk;
  parameter int A = -3;
  class c; localparam int Q = -4; endclass
endpackage
module dut(output int o);
  ifc i0();
  assign o = 0;
endmodule
