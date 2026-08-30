// r10v164 ARM E -- THE CLASS-HOME ATTACK.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// The implementer's model says a cast operand falls through Surelog's
//     if (pexpr) ... else if (instance) ... else needLateBinding
// to the INSTANCE, so the suppression is owed only where there is no instance.
// Arm B measured the MODULE-function face.  This arm attacks the other half of
// that claim: a CLASS METHOD whose class is declared somewhere that HAS an
// instance -- inside a module, inside an interface, inside a program, and at
// $unit scope -- against the package-class control.  If golden BINDS a cast
// operand in an `if` condition in any of those, the patched binary must not
// take it away.
//
// Names are deliberately unrelated to each other, to the arm letter and to the
// implementer's names (an a_t/b_t/c_t grid confirms itself).

package quarry164;
  typedef enum bit [1:0] {SLATE, GRANITE, BASALT} rock_e;
  int unsigned seam = 4;
  class Hewer;                                  // e00 -- the PACKAGE control
    int chisel = 11;
    function automatic int strike(int unsigned heft);
      int wedge = 3;
      if (int'(wedge) == 3)      chisel = 1;    // e01 cast LOCAL  pkg class
      if (int'(heft) == 5)       chisel = 2;    // e02 cast FORMAL pkg class
      if (wedge == 3)            chisel = 3;    // e03 bare LOCAL  (control)
      case (int'(heft))
        5:       chisel = 4;                    // e04 cast FORMAL case cond
        default: chisel = 5;
      endcase
      return chisel;
    endfunction
  endclass
endpackage

// ---------------------------------------------------------------------------
// e10 -- a class declared at $UNIT scope (compilation-unit).  No instance and
// no package: the `else if (component)` needLateBinding leg.
// ---------------------------------------------------------------------------
class Drover164;
  int tally = 21;
  function automatic int herd(int unsigned head);
    int prod = 6;
    if (int'(prod) == 6)         tally = 1;     // e11 cast LOCAL  $unit class
    if (int'(head) == 2)         tally = 2;     // e12 cast FORMAL $unit class
    if (prod == 6)               tally = 3;     // e13 bare LOCAL  (control)
    return tally;
  endfunction
endclass

// ---------------------------------------------------------------------------
// e20 -- a class declared INSIDE A MODULE.  The module HAS an instance, so
// Surelog's `else if (instance)` leg is live here if it is live anywhere.
// ---------------------------------------------------------------------------
module kiln164;
  int flue = 30;
  class Stoker;
    int damper = 31;
    function automatic int bank(int unsigned coke);
      int ember = 7;
      if (int'(ember) == 7)      damper = 1;    // e21 cast LOCAL  module class
      if (int'(coke) == 9)       damper = 2;    // e22 cast FORMAL module class
      if (ember == 7)            damper = 3;    // e23 bare LOCAL  (control)
      case (int'(ember))
        7:       damper = 4;                    // e24 cast LOCAL case cond
        default: damper = 5;
      endcase
      if (int'(flue) == 30)      damper = 6;    // e25 cast MODULE var
      return damper;
    endfunction
    task automatic stoke(int unsigned rake);
      int poker = 8;
      if (int'(poker) == 8)      damper = 7;    // e26 cast LOCAL  module-class TASK
      if (int'(rake) == 1)       damper = 8;    // e27 cast FORMAL module-class TASK
    endtask
  endclass
  Stoker st;
  int outcome20;
  initial begin
    st = new();
    outcome20 = st.bank(9);
    st.stoke(1);
  end
endmodule

// ---------------------------------------------------------------------------
// e30 -- a class declared inside an INTERFACE, and e40 inside a PROGRAM.
// ---------------------------------------------------------------------------
interface conduit164;
  logic sluice;
  class Warden;
    int gate = 41;
    function automatic int shut(int unsigned lever);
      int latch = 12;
      if (int'(latch) == 12)     gate = 1;      // e31 cast LOCAL  iface class
      if (int'(lever) == 4)      gate = 2;      // e32 cast FORMAL iface class
      if (latch == 12)           gate = 3;      // e33 bare LOCAL  (control)
      return gate;
    endfunction
  endclass
endinterface

program prospect164;
  class Assayer;
    int grade = 51;
    function automatic int weigh(int unsigned ore);
      int scale = 13;
      if (int'(scale) == 13)     grade = 1;     // e41 cast LOCAL  program class
      if (int'(ore) == 6)        grade = 2;     // e42 cast FORMAL program class
      if (scale == 13)           grade = 3;     // e43 bare LOCAL  (control)
      return grade;
    endfunction
  endclass
  Assayer ay;
  int outcome40;
  initial begin
    ay = new();
    outcome40 = ay.weigh(6);
  end
endprogram

// ---------------------------------------------------------------------------
// e50 -- a class NESTED inside another class, itself inside a module; plus an
// EXTENDED class's method (the derived body is a different scope object).
// ---------------------------------------------------------------------------
module foundry164;
  class Outer;
    int crucible = 61;
    class Inner;
      int mould = 62;
      function automatic int pour(int unsigned melt);
        int ingot = 14;
        if (int'(ingot) == 14)   mould = 1;     // e51 cast LOCAL  nested class
        if (int'(melt) == 7)     mould = 2;     // e52 cast FORMAL nested class
        if (ingot == 14)         mould = 3;     // e53 bare LOCAL  (control)
        return mould;
      endfunction
    endclass
  endclass
  class Basis;
    int anvil = 71;
    virtual function int forge(int unsigned blow);
      int tong = 15;
      if (int'(tong) == 15)      anvil = 1;     // e54 cast LOCAL  virtual base
      return anvil;
    endfunction
  endclass
  class Derived extends Basis;
    virtual function int forge(int unsigned blow);
      int rasp = 16;
      if (int'(rasp) == 16)      anvil = 2;     // e55 cast LOCAL  override
      if (int'(blow) == 3)       anvil = 3;     // e56 cast FORMAL override
      return anvil;
    endfunction
  endclass
  Outer::Inner ni;
  Derived dv;
  int outcome50;
  initial begin
    ni = new();
    dv = new();
    outcome50 = ni.pour(7) + dv.forge(3);
  end
endmodule

module harness164_e;
  quarry164::Hewer hw;
  Drover164 dr;
  conduit164 cd();
  int outcome;
  initial begin
    hw = new();
    dr = new();
    outcome = hw.strike(5) + dr.herd(2);
  end
endmodule
