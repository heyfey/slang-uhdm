// r10uvm131 arm D — 1..3 INSTANCES of one fork-bearing module: the DEF view
// carries one copy, the ELAB view one per instance.
module ForkLeaf #(parameter int WHICH = 0) (input logic go);
  int v;
  always @(posedge go) begin
    fork : leafNamed
      v = WHICH;
    join_none
    fork
      v = WHICH + 1;
    join_any
    pre_leaf : fork
      v = WHICH + 2;
    join
  end
endmodule

module ArmDMult(input logic go);
  ForkLeaf #(.WHICH(5)) u_one (.go(go));
  ForkLeaf #(.WHICH(6)) u_two (.go(go));
  ForkLeaf #(.WHICH(7)) u_tri (.go(go));
endmodule
