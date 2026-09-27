// § bareDecUnderscoreDropped181 — break hunt: a macro-born literal with separators, a negated one, a package parameter, a 20-digit one, a part-select bound and a replication count
`define N 1_0
package p; parameter int PP = 2_000; endpackage
module top(output logic [63:0] a, output logic [15:0] b, output logic [7:0] c, output logic [11:0] d);
  assign a = 64'(-1_0) + 1_8446_7440_7370_9551_615;
  assign b = `N + p::PP;
  assign c = {2{4'(1_1)}};
  assign d = {1_2{1'b1}};
endmodule
