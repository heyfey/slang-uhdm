// r10v156 ADVERSARIAL ARM 2 — a FORWARD-DECLARED class, a typedef of a typedef
// of a class, PARAMETERIZED classes with ONE and TWO specializations, and a
// return typed by a TYPE PARAMETER.  MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.

package pfwv6;
  typedef class Fwdv6;                       // forward declaration
  class Holdv6;
    function Fwdv6 r_fwd_same(); return null; endfunction     // fwd-declared, SAME pkg
  endclass
  class Fwdv6;
  endclass
  typedef Fwdv6 TdFwdv6;
  typedef TdFwdv6 TdTdFwdv6;                 // typedef of a typedef
  class Tdv6;
    function TdFwdv6   r_td();   return null; endfunction
    function TdTdFwdv6 r_tdtd(); return null; endfunction
  endclass
  class Parv6 #(type T = int);
    function Parv6#(T) r_self_spec(); return null; endfunction
  endclass
  class UsePv6;
    function Parv6#(int)    r_pi(); return null; endfunction  // specialization 1
    function Parv6#(bit)    r_pb(); return null; endfunction  // specialization 2
  endclass
  class Tprv6 #(type U = Fwdv6);
    function U r_tp(); return null; endfunction               // return via TYPE PARAMETER
  endclass
  class Anchv6;
    Tprv6#(Fwdv6) a1;
    Parv6#(int)   a2;
    Parv6#(bit)   a3;
  endclass
endpackage

package pfwv6b;
  import pfwv6::*;
  class Outv6;
    function Fwdv6       r_fwd_far(); return null; endfunction // fwd-declared, FAR pkg
    function Parv6#(int) r_pi_far();  return null; endfunction // far-pkg specialization
  endclass
  function Fwdv6 pfv6b_fwd(); return null; endfunction
endpackage
