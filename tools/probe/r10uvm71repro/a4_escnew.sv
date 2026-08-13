// r10uvm71 VERIFIER arm a4 -- THE OVER-FIRE CELL the README's law excludes by
// assertion: "a subroutine named `new` is a constructor and nothing else --
// `new` is a keyword, so no package- or module-level function can carry the
// name".  ESCAPED IDENTIFIERS are exempt from keyword rules: `\new ` is a legal
// ordinary identifier.  If slang names such a subroutine "new", the gate
// `sub.name == "new" && classScope` fires on a NON-constructor.
//
//   c_esc::\new       -- class METHOD named `new` via escaped identifier, WITH
//                        body locals.  golden must KEEP them (it is not a ctor).
//   p4::\new          -- PACKAGE function named `new` via escaped identifier.
//   c_esc::new        -- the real constructor, as the positive control.

package p4;

  class c_esc;
    int m_e;

    // NOT a constructor: an ordinary method whose NAME is the escaped
    // identifier `\new `.  It must keep its body local.
    function int \new (int a);
      int esc_meth_loc;
      esc_meth_loc = a + 1;
      return esc_meth_loc;
    endfunction

    function int plain_meth(int a);   // control
      int plain_loc;
      plain_loc = a;
      return plain_loc;
    endfunction
  endclass

  // PACKAGE-level function named `new` via escaped identifier.
  function int \new (int a);
    int pkg_new_loc;
    pkg_new_loc = a;
    return pkg_new_loc;
  endfunction

endpackage

module a4;
  import p4::*;
  c_esc h;
  int r;
  initial begin
    h = new();
    r = h.\new (2) + h.plain_meth(3) + p4::\new (4);
  end
endmodule
