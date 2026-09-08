// v209 verifier arm J — THE § 26 FACES, HOISTED.  Every qualifier/initializer
// shape § 26 decodes at package scope, written instead as a constructor body
// local, beside its package-scope twin.  The law says the § 26 test does not
// apply inside a subroutine body; this arm is where a wrong reading shows.
package pj209;
  class cj209a;
    int n;
    static function cj209a get();
      cj209a g;
      g = new();
      return g;
    endfunction
  endclass
  typedef cj209a cj209t;
  // package-scope twins (§ 26's own measured set) — must not move
  cj209a pj_plain;
  cj209a pj_new = new();
  const cj209a pj_const = cj209a::get();
  var cj209a pj_var;
  int    pj_int;
  string pj_str = "s";
  class cj209b;
    int q;
    extern function new();
  endclass
  function cj209b::new();
    cj209a       lj_plain;
    cj209a       lj_new = new();
    const cj209a lj_const = cj209a::get();
    var cj209a   lj_var;
    cj209t       lj_typedef;
    cj209a       lj_from_other;
    int          lj_int;
    string       lj_str = "t";
    lj_plain = null;
    lj_from_other = lj_plain;
    q = 4;
  endfunction
endpackage

import pj209::*;

module gj209;
  initial $display("j");
endmodule
