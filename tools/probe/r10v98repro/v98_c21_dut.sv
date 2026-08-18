// v98_c21 — THE BREAK CANDIDATE.  Golden's first writer for the racing name is
// an INTERFACE-level typedef (`getModuleDefinitions()` is keyed `lib@name` and
// carries modules AND interfaces, group 2, BEFORE all classes).  The patch's
// winner table walks only TOP instances, so it picks the first CLASS instead.
// The interface's typedef has the SAME judge-visible payload as the base
// class's own (int_typespec / wk21_t), so PRISTINE agrees with golden on every
// field uhdm-cmp reads and the PATCH moves it to bit_typespec.
package p21v;
  class a21win98v;  typedef bit [7:0] wk21_t; endclass
  class m21base98v; typedef int wk21_t; endclass
  class z21der98v extends m21base98v;
    function void hot(wk21_t x); endfunction
  endclass
endpackage
interface aif21v;
  typedef int wk21_t;
  wk21_t w;
endinterface
module top21v;
  p21v::z21der98v z;
  initial z = new();
endmodule
