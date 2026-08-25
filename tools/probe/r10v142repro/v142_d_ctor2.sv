// r10v142 verifier arm D — the CONSTRUCTOR face, widened: module class, an
// extended class, super.new, and the ESCAPED-IDENTIFIER `\new` control (an
// ORDINARY method that slang also names "new" — a NAME test would over-fire
// here, MethodFlags::Constructor does not).
package pv4142;
  class Kv4142;
    int f;
  endclass
  class Bv4142;
    function new;
      Kv4142 bct_n;
      Kv4142 bct_i = new();
    endfunction
  endclass
  class Dv4142 extends Bv4142;
    function new;
      Kv4142 dct_n;
      Kv4142 dct_i = new();
      super.new();
    endfunction
  endclass
  class Ev4142;
    function void \new ;                 // ESCAPED identifier: an ORDINARY method
      Kv4142 esc_n;
      Kv4142 esc_i = new();
    endfunction
  endclass
  class Fv4142;
    function void \new2 ();
      Kv4142 escb_n;
    endfunction
  endclass
endpackage

module mv4142;
  import pv4142::*;
  class Mk4142;
    int f;
  endclass
  class Mc4142;
    function new;
      Mk4142 mct_n;
      Mk4142 mct_i = new();
      Kv4142 mctp_i = new();
    endfunction
  endclass
  class Md4142;
    function new();
      Mk4142 mcb_n;
      Kv4142 mcbp_i = new();
    endfunction
  endclass
  class Mf4142;
    function void mtf4142;
      Mk4142 mf_n;
      Kv4142 mfp_n;
    endfunction
  endclass
endmodule
