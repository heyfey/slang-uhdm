// vsd10 adversarial cell v15 — the shape the V-FIX's `oneSeg` term newly sends
// to the fallback: a class's OWN typedef named with the FULL package-qualified
// scope, and an EARLY sibling named the same way.
package px15;
  class a15;
    typedef struct { int a; } a_t;
  endclass
  class m15;
    typedef struct { int m; } m_t;
    function void f();
      px15::m15::m_t v_self_multiseg;   // OWN typedef, TWO segments
      m15::m_t       v_self_oneseg;     // control: ONE segment
      px15::a15::a_t v_sib_multiseg;    // EARLY sibling, TWO segments
      a15::a_t       v_sib_oneseg;      // control: ONE segment
      v_self_multiseg.m = 1; v_self_oneseg.m = 2;
      v_sib_multiseg.a  = 3; v_sib_oneseg.a  = 4;
    endfunction
  endclass
endpackage
module top15;
  px15::m15 u;
  initial u = new();
endmodule
