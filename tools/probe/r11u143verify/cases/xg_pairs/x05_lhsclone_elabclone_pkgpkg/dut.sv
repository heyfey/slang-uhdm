// § impPaLhsDisjointClone133 + § elabCloneFullNameUnstored137 (cross-ground pair, judged in --elabuhdm too)
// case x05: a package importing a package, read in a sub-module's always block
package b5; parameter int K = 3; endpackage
package d5; import b5::*; localparam int KK = K + 1; endpackage
module sub(input logic [3:0] a, output logic [3:0] y);
  always_comb y = a + d5::KK;
endmodule
module dut(input logic [3:0] a, output logic [3:0] y); sub u(.a(a), .y(y)); endmodule
