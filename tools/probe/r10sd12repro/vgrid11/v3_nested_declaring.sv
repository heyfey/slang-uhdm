// vsd11 v3 — NESTED DECLARING CLASSES, the class of regression vgrid10 caught
// in r10sd10.  `surelogClassKey11` spells a nested class `pkg::Outer::Inner`;
// if Surelog registers it differently the CONTAINER half of the claim key is
// wrong and the race is decided the wrong way round.  Here the two competing
// typedefs sit at DIFFERENT nesting depths over the SAME target, so the answer
// depends on the spelling and on nothing else.
package pv3;

  class zel3;
    int q;
  endclass

  class zm3;
    int q;
  endclass

  class aouter3;                    // "pv3::aouter3"
    typedef zel3 t_out;             // key (4, "pv3::aouter3", "t_out")
    class binner3;                  // "pv3::aouter3::binner3"?  or "pv3::binner3"?
      typedef zel3 s_in;            // key (4, "pv3::aouter3::binner3", "s_in")
      typedef zm3  m_in;            // the only typedef naming zm3 -> claims
      function void f3();
        aouter3::t_out  v_out;      // the CLAIMANT of zel3 (t_out sorts first)
        binner3::s_in   v_in;       // the LOSER
        binner3::m_in   v_m;        // claims its own target
        v_out = null;
        v_in = null;
        v_m = null;
      endfunction
    endclass
  endclass

  // A third competitor at TOP level of the package, sorting between the two
  // class containers only if the nested spelling is the long one.
  class zz3;
    typedef zel3 a_zz;              // key (4, "pv3::zz3", "a_zz")
    function void g3();
      zz3::a_zz w_zz;
      w_zz = null;
    endfunction
  endclass

endpackage

module topv3;
  initial begin
    pv3::aouter3::binner3 b = new();
    pv3::zz3 z = new();
    b.f3();
    z.g3();
  end
endmodule
