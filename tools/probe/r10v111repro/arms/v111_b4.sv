// r10v111 ARM B4 — $unit-SCOPE CLASS and a PARAMETERISED CLASS.
class Unitk4;
  extern static function int umk4();
endclass
function int Unitk4::umk4();
  umk4 = 44;
endfunction

package v111b4p;
  class Par4 #(int W = 8);
    extern static function int pmk4();
  endclass
  function int Par4::pmk4();
    pmk4 = 4;
  endfunction
  int p_v4 = Par4#(8)::pmk4();
  int u_v4 = Unitk4::umk4();
endpackage

package v111b4w;
  import v111b4p::*;
  int wp_v4 = Par4#(8)::pmk4();
endpackage

module v111b4m;
  int mm4 = Unitk4::umk4();
endmodule
