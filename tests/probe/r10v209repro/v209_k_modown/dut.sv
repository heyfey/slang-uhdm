// v209 verifier arm K — A MODULE'S OWN VARIABLES beside a materialised import.
// A module variable is static in both producers; the law's gate must leave
// every one of them unmarked while the hoisted copies above them move.
package pk209;
  class ck209a;
    int n;
  endclass
  ck209a pk_h;
  int    pk_i;
  class ck209b;
    int q;
    extern function new();
  endclass
  function ck209b::new();
    ck209a lk_h;
    int    lk_i;
    lk_h = null;
    q = 6;
  endfunction
endpackage

module gk209;
  import pk209::*;
  ck209a mk_h;
  int    mk_i;
  logic [3:0] mk_v;
  string mk_s;
  initial begin
    mk_h = null;
    mk_i = 0;
    $display("k");
  end
endmodule
