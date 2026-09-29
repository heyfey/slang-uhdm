// § tfArgScalarTdWriter223 — extern prototypes with out-of-body definitions in a $unit class and a class declared inside a module
package p;
  typedef int UF_T;
endpackage
import p::*;
class uc;
  extern function void set(UF_T f);
  extern static function int get(UF_T f, UF_T g);
endclass
function void uc::set(UF_T f); endfunction
function int uc::get(UF_T f, UF_T g); return f + g; endfunction
module top;
  class mc;
    extern function void put(UF_T f);
  endclass
  function void mc::put(UF_T f); endfunction
endmodule
