// § procReplCountOwner254 (fresh: a count inside a nested replication, inside a streaming concatenation operand and in an inc/dec context, in a named block of a child instance)
package pk; parameter int N = 2; endpackage
module leaf import pk::*; ();
  logic [7:0] q, r; int c;
  always_comb begin : nb
    q = {N{{N{2'b01}}}};
    r = {<<{ {N{4'b0011}} }};
    c = 0; c++;
  end
endmodule
module top; leaf l(); endmodule
