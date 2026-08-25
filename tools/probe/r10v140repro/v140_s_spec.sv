// r10v140 arm S — parameterised class specialised TWICE and THREE times, a
// class in $unit, 1/2/3 instances of an alias-returning module, and a
// FORWARD typedef resolved later.
typedef enum bit [1:0] { VANE_N = 1, VANE_S = 2 } vaneDir;
typedef vaneDir VaneDir_e;

class Weathercock #(type T = int, int W = 4);
  T held;
  function T holdBack(); return held; endfunction
  function VaneDir_e vaneOfSpec(); return VANE_N; endfunction
endclass

package Mill_pkg;
  typedef struct packed { bit [7:0] grain; } millWord;
  typedef millWord MillWord_s;
  typedef enum bit [2:0] { MILL_IDLE = 1, MILL_GRIND = 2, MILL_JAM = 4 } millPhase;
  typedef millPhase MillPhase_e;
  typedef millPhase mill_phase_second;

  class Sail #(int BLADES = 3);
    MillPhase_e ph;
    function MillPhase_e sailPhase(); return ph; endfunction
    function millPhase sailBasePhase(); return ph; endfunction
    function MillWord_s sailWord(); MillWord_s w; return w; endfunction
    function mill_phase_second sailSecond(); return ph; endfunction
  endclass
endpackage

module vane_leaf;
  import Mill_pkg::*;
  function MillPhase_e leafPhase(); return MILL_GRIND; endfunction
  function millPhase leafBase(); return MILL_JAM; endfunction
  function MillWord_s leafWord(); MillWord_s w; return w; endfunction
endmodule

module vane_top;
  vane_leaf u_one();
  vane_leaf u_two();
  vane_leaf u_three();
  Weathercock #(VaneDir_e, 5) wc_a;
  Weathercock #(int, 6)       wc_b;
  Weathercock #(Mill_pkg::MillPhase_e, 7) wc_c;
  Mill_pkg::Sail #(2) sail_two;
  Mill_pkg::Sail #(9) sail_nine;
endmodule
