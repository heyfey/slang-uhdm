// § parseViewSizeExprEval228 — a package variable operand, package-qualified
package p;
  bit [3:0][1:0] pv;
endpackage
module dut (output logic [7:0] o1);
  wire [7:0] w1 = $size(p::pv);
  assign o1 = w1;
endmodule
