// vsd11 v5 — INTERFACE CLASSES and INHERITED typedefs.
// (a) An INTERFACE CLASS is a ClassType in slang, so `collectTdClaims11` walks
//     its typedefs and they enter the race.  Does Surelog's bindTypedefs_ see
//     them the same way?
// (b) `Derived::td` where `td` is INHERITED: `scopedTdLeaf11` uses
//     `ClassType::find`, which does not search base classes, so the predicate
//     declines.  Measured rather than assumed.
package pv5;

  class zel5;
    int q;
  endclass

  interface class ai5;
    typedef zel5 i_t;          // interface-class typedef: (4, "pv5::ai5", "i_t")
    pure virtual function void go();
  endclass

  class zbase5;
    typedef zel5 base_t;       // (4, "pv5::zbase5", "base_t")
    typedef int  binplace_t;
  endclass

  class zderv5 extends zbase5 implements ai5;
    typedef zel5 derv_t;       // (4, "pv5::zderv5", "derv_t")
    virtual function void go(); endfunction
    function void f5();
      zbase5::base_t  v_base;      // written on the DECLARING class
      zderv5::base_t  v_inherited; // written on the DERIVED class
      zderv5::derv_t  v_derv;
      ai5::i_t        v_iface;
      zbase5::binplace_t v_inplace;
      v_base = null;
      v_derv = null;
    endfunction
  endclass

endpackage

module topv5;
  initial begin
    pv5::zderv5 d = new();
    d.f5();
  end
endmodule
