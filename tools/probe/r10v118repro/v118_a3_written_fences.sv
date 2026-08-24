// r10v118 arm W — WRITTEN-cast fences.  Every row has a literal `'`, so golden
// must carry a vpiCastOp and the patch must KEEP ours.
package Vault9;
  typedef string Moniker;
  typedef bit [11:0] Dozen_t;
  function automatic string brew(int unsigned qty);
    string Tally;
    Tally = {"qty=", string'(qty), ";"};              // W-A written string' in string concat
    Tally = {Tally, Moniker'(qty)};                   // W-B via package typedef
    Tally = {Tally, string'(int'(qty))};              // W-C nested written casts
    Tally = {Tally, const'(Tally)};                   // W-G const' on a STRING -> SignedCastExpr
    Tally = string'(qty);                             // W-H outside any concat
    Tally = $sformatf("%0d", {Dozen_t'(qty), 4'hE});  // W-J written cast, NON-string concat
    Tally = {Tally, string'((qty > 7) ? 8'd3 : 8'd9)};// W-L written cast over a ternary
    Tally = {Tally, string'(12'(qty))};               // W-M nested sized cast
    return Tally;
  endfunction
endpackage

module Weft77;
  string Ledger;
  int unsigned Reckon;
  initial begin
    Reckon = 41;
    Ledger = {"R:", string'(Reckon)};                 // W-K module initial
    Ledger = {Ledger, const'(Ledger), "!"};           // W-N const' in a module process
    $display("%s", Vault9::brew(Reckon));
  end
endmodule
