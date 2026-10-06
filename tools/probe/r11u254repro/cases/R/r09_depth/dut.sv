// § procReplCountOwner254 (the process in a child instance at depth 2 and 3)
package pk;
  parameter int N = 3;
endpackage
module leaf import pk::*; ();
  logic [5:0] q;
  always_comb q = {N{2'b10}};
endmodule
module mid; leaf l(); endmodule
module top; mid m(); leaf l0(); endmodule
