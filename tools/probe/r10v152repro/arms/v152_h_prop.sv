// r10v152 arm H — THE R0 SHAPE.  A CLASS PROPERTY read inside an out-of-body
// constructor at package scope, where the PACKAGE listing carries a variable of
// the same name (here supplied by ANOTHER constructor's collected block item,
// exactly as uvm_pkg::clp is).
package proppkg;
  class Lamp; int lm; endclass

  class Donorc;
    int dz;
    extern function new();
  endclass
  function Donorc::new();
    Lamp gadget;                   // eaten -> package copy named `gadget`
    Lamp spare;
    gadget = null;
    spare  = null;
    dz = 1;
  endfunction

  class Owner;
    Lamp gadget;                   // a CLASS PROPERTY of the same name
    static Lamp statgadget;        // and a STATIC one
    int oz;
    extern function new();
    extern function void meth();
  endclass
  function Owner::new();
    Lamp eaten_here;               // eaten
    eaten_here = null;             // h01 the law
    gadget     = null;             // h02 CLASS PROPERTY, package copy exists
    statgadget = null;             // h03 STATIC property
    oz = 2;
  endfunction
  function void Owner::meth();
    gadget = null;                 // h04 property in an ordinary OOB method
  endfunction

  Lamp statgadget;                 // package variable colliding with the static
endpackage

module mprop;
  import proppkg::*;
  Donorc dc; Owner ow;
  initial begin dc = new(); ow = new(); ow.meth(); end
endmodule
