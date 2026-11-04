// § procReplCountOwner254 (a replication count in an unnamed always_comb, an initial and a nested concatenation)
package pk;
  parameter int N = 3;
endpackage
module top;
  import pk::*;
  logic [5:0] q;
  logic [8:0] r;
  always_comb q = {N{2'b10}};
  initial r = {{N{2'b10}}, {N{1'b1}}};
endmodule
