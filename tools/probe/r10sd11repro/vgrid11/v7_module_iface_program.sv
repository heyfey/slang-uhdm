// vsd11 v7 — THE CLAIM TABLE'S BLIND SPOTS, made to matter.
// `buildTdClaims11` walks compilation units, packages and TOP INSTANCE bodies
// only.  It never walks a NESTED module instance, an INTERFACE, a PROGRAM, a
// GENERATE block, or an UNINSTANTIATED module.  Every miss can only make the
// predicate answer "claimed" (unchanged), which is the safe direction — this
// cell MEASURES that claim instead of asserting it, by putting the would-be
// claimant in each blind spot and reading golden's verdict on the class typedef
// that the miss then lets resolve.
package pv7;
  class zel7;
    int q;
  endclass
  class zsub7;
    int q;
  endclass
  class zif7;
    int q;
  endclass
  class zgen7;
    int q;
  endclass

  class zc7;
    typedef zel7  c_top;       // competitor lives in the TOP module   (seen)
    typedef zsub7 c_sub;       // competitor lives in a NESTED instance (missed)
    typedef zif7  c_if;        // competitor lives in an INTERFACE      (missed)
    typedef zgen7 c_gen;       // competitor lives in a GENERATE block  (missed)
    function void f7();
      zc7::c_top v_top;
      zc7::c_sub v_sub;
      zc7::c_if  v_if;
      zc7::c_gen v_gen;
      v_top = null;
      v_sub = null;
    endfunction
  endclass
endpackage

interface ifv7;
  typedef pv7::zif7 if_t;      // an INTERFACE typedef claiming zif7
endinterface

module subv7;
  typedef pv7::zsub7 sub_t;    // a NESTED-instance typedef claiming zsub7
endmodule

module topv7;
  typedef pv7::zel7 top_t;     // a TOP-instance typedef claiming zel7
  subv7 s();
  ifv7  i();
  if (1) begin : gblk
    typedef pv7::zgen7 gen_t;  // a GENERATE-block typedef claiming zgen7
  end
  initial begin
    pv7::zc7 c = new();
    c.f7();
  end
endmodule
