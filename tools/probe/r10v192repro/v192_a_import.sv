// r10v192 ARM A — IMPORT FORMS AND TRANSITIVE CLONES.  MEASUREMENT ONLY.
package baseP;
  class Rod;
    extern static function int len();
    extern static function int rodCaller();
  endclass
  function int Rod::len();
    return 7;
  endfunction
  function int Rod::rodCaller();
    return Rod::len();
  endfunction
endpackage

// EXPLICIT ITEM import, not wildcard: does itemP's listing carry clones?
package itemP;
  import baseP::Rod;
  class Cog;
    extern static function int spin();
    extern static function int cogCaller();
  endclass
  function int Cog::spin();
    return 11;
  endfunction
  function int Cog::cogCaller();
    return Rod::len() + Cog::spin();
  endfunction
endpackage

// TRANSITIVE wildcard: midP imports+exports baseP, topP imports midP.
package midP;
  import baseP::*;
  export baseP::*;
  class Gear;
    extern static function int teeth();
  endclass
  function int Gear::teeth();
    return Rod::len();
  endfunction
endpackage

package topP;
  import midP::*;
  class Hub;
    extern static function int bore();
  endclass
  function int Hub::bore();
    return Gear::teeth();
  endfunction
endpackage

module v192a_top;
  import topP::*;
  int r;
  initial r = Hub::bore();
endmodule
