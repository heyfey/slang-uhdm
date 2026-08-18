// r10uvm98 arm a3 — WHERE the winner may live.  bindTypedefs_ walks
// FileContents, then packages, then modules, then programs, then classes;
// compileDatastructureTypespec ALSO has an all-FileContents fallback that
// resolves a $unit name before any late binding happens.
typedef int unit_t;                       // $unit / FileContent home

package apkg98;                           // alphabetically FIRST package
  typedef byte pkgwin_t;                  // a PACKAGE-level typedef
endpackage

package zpkg98;
  class kbase98 #(type T = int);
    typedef kbase98 #(T) pkgwin_t;        // a CLASS declaring the same name
    typedef shortint unit_t;              // a CLASS declaring the $unit name
    typedef logic own98_t;
  endclass
  class kderv98 extends kbase98 #(int);
    task uses();
      pkgwin_t a;                         // inherited AND package-declared
      unit_t   b;                         // inherited AND $unit-declared
      own98_t  c;                         // inherited only
    endtask
  endclass
endpackage

module mtop98c;
  typedef real mod98_t;
  import zpkg98::*;
  kbase98 #(int) hb;
  kderv98 hd;
  initial begin hb = new(); hd = new(); end
endmodule
