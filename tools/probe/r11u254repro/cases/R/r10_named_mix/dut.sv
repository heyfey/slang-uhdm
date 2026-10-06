// § procReplCountOwner254 (a named block: a count with an operation, a plain operand fold, a select index fold and a count inside a nested concatenation)
package pk;
  parameter int N = 3;
endpackage
module top;
  import pk::*;
  logic [7:0] r;
  logic [1:0] e;
  int x;
  always_comb begin : nb
    r = {N+1{e}};
    x = N + 1;
    x = e[N-2];
    r = {e, {N{e}}};
  end
endmodule
