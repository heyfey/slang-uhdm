// r10v180 arm H — THE SPELLING CONTROL.  A wildcard-import CLONE body that
// spells the typedef EXPLICITLY QUALIFIED (`Anvil_pk::rivet_t`) beside one
// that spells it bare, plus the HOME body spelling it both ways.  If golden
// keeps the qualified spelling anywhere the law's blanket re-point is wrong.
// Also a typedef OF a typedef and a chained alias, which give the alias walk
// two links to confuse.
package Anvil_pk;
  typedef logic [12:0] rivet_t;
  typedef rivet_t       flange_t;      // a typedef OF a typedef
  function automatic int unsigned forge_fn(rivet_t stock);
    rivet_t plain;
    Anvil_pk::rivet_t spelled;         // explicitly qualified, in the HOME
    flange_t chained;
    plain = stock;
    spelled = Anvil_pk::rivet_t'(plain);
    chained = flange_t'(plain);
    begin
      rivet_t           deep_plain;
      Anvil_pk::rivet_t deep_spelled;
      flange_t          deep_chained;
      deep_plain   = plain;
      deep_spelled = Anvil_pk::rivet_t'(spelled);
      deep_chained = flange_t'(chained);
      plain = rivet_t'(int'(deep_plain) + int'(deep_spelled) +
                       int'(deep_chained));
    end
    return int'(plain) + int'(spelled) + int'(chained);
  endfunction
endpackage
package Anvil_imp;
  import Anvil_pk::*;
endpackage
module Anvil_top;
  import Anvil_pk::*;
  rivet_t bar;
  int unsigned r;
  initial begin
    bar = 13'h0abc;
    r = forge_fn(bar);
  end
endmodule
