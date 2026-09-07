// r10v192 ARM B — CROSS-PACKAGE CLASS-NAME COLLISION, the fence-3 name-only
// ownership test and the fence-4 FIRST-MATCH multiplicity.  MEASUREMENT ONLY.
package alphaP;
  class Same;
    extern static function int val();
    extern static function int alphaCaller();
  endclass
  function int Same::val();
    return 2;
  endfunction
  function int Same::alphaCaller();
    return Same::val();
  endfunction
endpackage

// betaP owns its OWN class also named Same.
package betaP;
  class Same;
    extern static function int val();
    extern static function int betaCaller();
  endclass
  function int Same::val();
    return 3;
  endfunction
  function int Same::betaCaller();
    return Same::val() + alphaP::Same::val();
  endfunction
endpackage

// gammaP imports alphaP WILDCARD and owns NO class named Same: its listing
// carries alphaP's clone bodies, and its OWN body calls the imported static.
package gammaP;
  import alphaP::*;
  class Wheel;
    extern static function int roll();
  endclass
  function int Wheel::roll();
    return Same::val();
  endfunction
endpackage

// deltaP imports alphaP WILDCARD **and** declares its OWN Same, so its
// listing can hold TWO entries named `Same::val` — the first-match risk.
package deltaP;
  import alphaP::*;
  class Same;
    extern static function int val();
    extern static function int deltaCaller();
  endclass
  function int Same::val();
    return 5;
  endfunction
  function int Same::deltaCaller();
    return Same::val();
  endfunction
endpackage

module v192b_top;
  import deltaP::*;
  int r;
  initial r = deltaP::Same::deltaCaller() + gammaP::Wheel::roll();
endmodule
