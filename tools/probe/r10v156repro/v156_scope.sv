// r10v156 ADVERSARIAL ARM 3 — a SCOPED return naming the class's OWN package,
// a virtual method return in a DERIVED class, an extern STATIC out-of-body,
// and a $unit free function.  MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.

package pdv6;
  class BaseDv6;
    virtual function BaseDv6 clone_me(); return null; endfunction  // same pkg, virtual
  endclass
  class DerDv6 extends BaseDv6;
    virtual function BaseDv6 clone_me(); return null; endfunction  // derived override
    virtual function DerDv6  clone_d();  return null; endfunction
  endclass
  class SDv6;
    extern static function DerDv6 mk();
  endclass
  function DerDv6 SDv6::mk(); return null; endfunction             // out-of-body STATIC
  function pdv6::DerDv6 pf_same_scoped(); return null; endfunction // SCOPED, SAME pkg
  function DerDv6       pf_same_bare();   return null; endfunction
endpackage

package pdov6;
  class Othv6;
    function pdv6::DerDv6 r_scoped_far(); return null; endfunction // SCOPED, far pkg
  endclass
  function pdv6::DerDv6 pf_scoped_far(); return null; endfunction
endpackage

class Unitv6;
endclass
function Unitv6 unit_free_v6(); return null; endfunction           // $unit FREE function

module mv6;
  Unitv6 u;
  initial u = unit_free_v6();
endmodule
