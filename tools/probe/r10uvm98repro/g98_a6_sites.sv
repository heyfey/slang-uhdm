// r10uvm98 arm a6 — the remaining CELLS: a class HOME in a module and in
// $unit, a `new()` argument, THREE live specializations of the declaring
// class, and the FORWARD use (a name written in the class body BEFORE its own
// typedef statement — `getDataType` cannot see it yet either).
class u98win;                             // $unit home, sorts as work@u98win
  typedef u98win fwd98_t;
endclass

package fpk98;
  class a1first98 #(type T = int);
    typedef a1first98 #(T) spec98_t;
    typedef a1first98 #(T) fwd98_t;
  endclass
  class b2decl98 #(type T = int);
    typedef b2decl98 #(T) spec98_t;
    function void mk(spec98_t p); endfunction
  endclass
  class c3use98 extends b2decl98 #(int);
    function new(spec98_t seed); super.new(); endfunction
    task t(); spec98_t v; endtask
  endclass
endpackage

module mhome98;
  class d4mod98;                          // a class whose HOME is a module
    typedef d4mod98 spec98_t;             // contests the name from group 2
    typedef int fwd98_t;
  endclass
  import fpk98::*;
  a1first98 #(int)    s1;
  a1first98 #(byte)   s2;
  a1first98 #(shortint) s3;               // THREE live specializations
  b2decl98 #(int) hb;
  c3use98 hc;
  d4mod98 hd;
  u98win  hu;
  initial begin s1 = new(); s2 = new(); s3 = new(); hb = new();
                hc = new(null); hd = new(); hu = new(); end
endmodule
