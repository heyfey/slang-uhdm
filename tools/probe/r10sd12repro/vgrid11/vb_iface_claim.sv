// vsd11 vb — DOES an INTERFACE-CLASS typedef enter the race at all?
// v5 measured that `pv5::ai5`'s `i_t` does NOT claim `zel5` even though it sorts
// first.  Two models: interface classes are EXCLUDED, or they are ordered LAST.
// Here the interface class is the ONLY typedef naming its target, so an
// EXCLUDED interface class leaves the target unclaimed (and `aif::only_t`
// resolves) while an ORDERED-LAST one still claims it.
package pvb;

  class zonlyb;
    int q;
  endclass

  class zsharedb;
    int q;
  endclass

  interface class aifb;
    typedef zonlyb   only_t;   // the ONLY typedef naming zonlyb
    typedef zsharedb shr_t;    // races zclsb::shr2_t for zsharedb
    pure virtual function void go();
  endclass

  class zclsb implements aifb;
    typedef zsharedb shr2_t;   // the class-side competitor
    virtual function void go(); endfunction
    function void fb();
      aifb::only_t v_only;     // interface class, sole namer
      aifb::shr_t  v_shr;      // interface class, races
      zclsb::shr2_t v_shr2;    // ordinary class, races
      v_only = null;
      v_shr = null;
      v_shr2 = null;
    endfunction
  endclass

endpackage

module topvb;
  initial begin
    pvb::zclsb c = new();
    c.fb();
  end
endmodule
