// v88 b1 — QUALIFICATION FORMS read from an IN-BODY class method.
// The gate blocks the pkgViewVarObjs9 bind for every in-body class method.
// If golden binds a `pkg::var` (compile-time resolved, not late-bound) and
// pristine bound it too, the gate is a REGRESSION on that cell.
package p1;
  const string cs1 = "CS";
  int          nv1 = 3;
  string       ss1 = "SS";
endpackage

package q1;
  import p1::*;                 // wildcard
  import p1::nv1;               // explicit
  const string qcs1 = "QCS";
  class kq1;
    string s; int i;
    function void inb_bare();      // bare, via wildcard import
      s = cs1;                     // p1::cs1 through the wildcard
      i = nv1;                     // p1::nv1 through the explicit import
      s = qcs1;                    // q1's OWN package const
    endfunction
    function void inb_qual();      // FULLY QUALIFIED p1::x
      s = p1::cs1;
      i = p1::nv1;
      s = p1::ss1;
      s = q1::qcs1;                // qualified read of its OWN package
    endfunction
    extern function void oob_bare();
    extern function void oob_qual();
  endclass
  function void kq1::oob_bare();
    s = cs1; i = nv1; s = qcs1;
  endfunction
  function void kq1::oob_qual();
    s = p1::cs1; i = p1::nv1; s = p1::ss1; s = q1::qcs1;
  endfunction
  // package function controls
  function void qf1();
    automatic string t;
    t = cs1; t = p1::cs1; t = qcs1; t = q1::qcs1;
  endfunction
endpackage

module topb1;
  q1::kq1 h;
  initial begin h = new(); h.inb_bare(); h.inb_qual(); q1::qf1(); end
endmodule
