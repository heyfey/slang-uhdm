// v131 arm B — EMPTY and near-empty forks: the gate's whole action surface.
module Bempty;
  int u3, v8;
  initial begin
    // empty unnamed
    fork join
    fork join_any
    fork join_none
    // empty named, no end label
    fork : eA join
    fork : eB join_any
    fork : eC join_none
    // empty named, WITH end label
    fork : eD join : eD
    fork : eE join_any : eE
    fork : eF join_none : eF
    // empty via outer label
    oL1 : fork join
    oL2 : fork join_any
    oL3 : fork join_none
    // NULL-STATEMENT-ONLY forks
    fork ; join
    fork : nS2 ; join_any
    fork : nS3 ; join_none : nS3
    // DECLARATION-ONLY forks
    fork int dOnly1 = 1; join
    fork : dcl2 int dOnly2 = 2; join_any
    fork : dcl3 int dOnly3 = 3; join_none : dcl3
    // non-empty controls next to them
    fork : fullA u3 = 41; join : fullA
    fork : fullB v8 = 42; join_none : fullB
    // begin controls (seq_block must be untouched)
    begin : emptyBeg end : emptyBeg
    begin : emptyBeg2 end
    begin : fullBeg u3 = 43; end : fullBeg
  end
endmodule
