// r10v156 ADVERSARIAL ARM 1 — INTERFACE CLASSES, class-in-generate,
// a class in an interface reached from outside, and a program free function.
// MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.

package pifv6;
  interface class ICv6;
    pure virtual function int gv();
  endclass
  class Implv6 implements ICv6;
    virtual function int gv(); return 1; endfunction
  endclass
  class Userv6;
    function ICv6   r_ic_same();  return null; endfunction  // interface class, SAME pkg
    function Implv6 r_im_same();  return null; endfunction  // ordinary class,  SAME pkg
  endclass
  function ICv6   pfv6_ic(); return null; endfunction        // pkg FREE fn, same pkg
  function Implv6 pfv6_im(); return null; endfunction
endpackage

package pifv6b;
  import pifv6::*;
  class Farv6;
    function ICv6   r_ic_far(); return null; endfunction     // far-pkg interface class
    function Implv6 r_im_far(); return null; endfunction
  endclass
  function ICv6 pfv6b_ic(); return null; endfunction
endpackage

module mgv6;
  class MOutv6;
  endclass
  function MOutv6 mo_v6(); return null; endfunction           // module free fn, same module
  if (1) begin : gbv6
    class GClsv6;
    endclass
    function GClsv6 gf_v6();  return null; endfunction        // GENERATE scope, same genblk
    function MOutv6 gf2_v6(); return null; endfunction        // GENERATE scope, module class
  end
  MOutv6 hv6;
  initial hv6 = new();
endmodule
