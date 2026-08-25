// r10uvm140 arm D — INSTANCE COUNT (1, 2 and 3 copies of the same
// alias-returning module) and a parameterised class, so a per-instance
// re-emission cannot hide the law.  The three counts sit in three DIFFERENT
// modules so the arm is not three copies of one cell.
package Cinder_pkg;
  typedef enum { Cold9 = 0, Warm9 = 3, Hot9 = 6 } heatBand;
  typedef heatBand HeatBand_e;
  typedef heatBand heat_band_t;
  typedef struct packed { logic [4:0] deg; } tempRec;
  typedef tempRec  TempRec_s;

  class Kiln #(int WIDTH = 4);
    function HeatBand_e paramAlias(); return Hot9;  endfunction
    function heatBand   paramBase();  return Cold9; endfunction
    function TempRec_s  paramRec();   TempRec_s r; return r; endfunction
  endclass
endpackage

module Ember(output int probe);
  import Cinder_pkg::*;
  function heat_band_t emberAlias(); return Warm9; endfunction
  function heatBand    emberBase();  return Cold9; endfunction
  assign probe = int'(emberAlias());
endmodule

module Hearth_one;
  int a1;
  Ember e1(.probe(a1));
endmodule

module Hearth_two;
  int b1, b2;
  Ember e1(.probe(b1));
  Ember e2(.probe(b2));
endmodule

module Hearth_three;
  import Cinder_pkg::*;
  int c1, c2, c3;
  Ember e1(.probe(c1));
  Ember e2(.probe(c2));
  Ember e3(.probe(c3));
  Kiln #(8) k8;
  Kiln #(3) k3;
  HeatBand_e hb;
  initial begin
    k8 = new(); k3 = new();
    hb = k8.paramAlias();
  end
endmodule

module Forge;
  Hearth_one   h1();
  Hearth_two   h2();
  Hearth_three h3();
endmodule
