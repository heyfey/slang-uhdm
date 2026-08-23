// r10uvm109repro/g109_a2.sv - THE `= new` CORNERS and the CLASS-KIND grid.
// MEASUREMENT ONLY.  Every property has its own name, so "one wire per NAME"
// cannot merge two cells.
class UnitScoped9;              // home = $unit (compilation unit), not a package
  int uHome4;
  extern function void uset();
endclass
function void UnitScoped9::uset();
  uHome4 = 3;                   // U1 plain LHS, $unit-home class
endfunction

package box2;

  class Leaf2;
    int q;
    function new(int a = 0); q = a; endfunction
  endclass

  class Holder2;
    Leaf2 sub2;
    function new(); sub2 = new(); endfunction
  endclass

  class BaseKit;
    Leaf2 baseNewX;             // B1 inherited property, `= new` in the DERIVED body
    int   basePlainY;           // B2 inherited property, plain LHS
    extern function void bset();
  endclass

  class DerivedKit extends BaseKit;
    Leaf2   copyNewA;
    Leaf2   ctorArgB;
    Holder2 pathNewC;           // `pathNewC.sub2 = new();`
    Leaf2   idxNewD[3];         // `idxNewD[1] = new();`
    Leaf2   ibNewE;             // the IN-BODY control
    static Leaf2 statNewF;
    extern function void dset(Leaf2 seed);
    // CONTROL: the SAME `= new` shape written INSIDE the class body.
    function void inbody_new();
      ibNewE = new(5);
    endfunction
  endclass

  class ParamKit #(type T = int);
    Leaf2 paramNewG;
    int   paramPlainH;
    extern function void pset();
  endclass

  function void BaseKit::bset();
    baseNewX   = new(1);        // B1
    basePlainY = 2;             // B2
  endfunction

  function void DerivedKit::dset(Leaf2 seed);
    Leaf2 locNewK;              // the uvm107 family CONTROL: a plain LOCAL
    copyNewA      = new seed;   // A1 COPY constructor
    ctorArgB      = new(9);     // A2 class-new with an argument
    pathNewC.sub2 = new();      // A3 hier_path LHS whose base is a property
    idxNewD[1]    = new();      // A4 indexed LHS whose base is a property
    statNewF      = new(4);     // A5 STATIC property
    locNewK       = new(6);     // A6 a plain LOCAL (uvm107's fence)
    baseNewX      = new(8);     // B1 again, from the derived body
    basePlainY    = 7;
  endfunction

  function void ParamKit::pset();
    paramNewG   = new(2);       // P1 parameterised class
    paramPlainH = 5;            // P2
  endfunction

endpackage

module top2;
  import box2::*;
  DerivedKit d2;
  ParamKit #(int) p2;
  UnitScoped9 u2;
  initial begin
    d2 = new();
    d2.dset(null);
    d2.inbody_new();
    d2.bset();
    p2 = new();
    p2.pset();
    u2 = new();
    u2.uset();
  end
endmodule
