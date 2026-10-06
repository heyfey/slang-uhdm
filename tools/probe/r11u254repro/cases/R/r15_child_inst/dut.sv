// § procReplCountOwner254 (child instances at depth 2 and 3: a named block, a function, a port connection and a continuous assignment, the elaborated instance path)
package pk;
  parameter int N = 3;
endpackage
module sub (input logic [5:0] a);
endmodule
module leaf import pk::*; ();
  logic [5:0] q, r, w;
  logic [1:0] e;
  function automatic logic [5:0] f(); return {N{2'b10}}; endfunction
  always_comb begin : nb q = {N{2'b01}}; r = f(); end
  assign w = {N{e}};
  sub s (.a({N{e}}));
endmodule
module mid; leaf l(); endmodule
module top; mid m(); leaf l0(); endmodule
