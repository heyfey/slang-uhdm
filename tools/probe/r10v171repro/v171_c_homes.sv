// r10v171 arm C — HOMES x INSTANCES.  The same select/receiver spellings on a
// return name, but in every HOME the emitter can put a subroutine in: a
// package free function (the law's home), a class IN-BODY method, a class
// OUT-OF-BODY method, a MODULE function, an INTERFACE function, and a
// function inside a generate block — with 1..3 instances of the module.
// The law says class methods and module/interface functions stay BARE
// everywhere; only the package free function's wildcard-import CLONE binds.
package homes_home_171;
  // (H1) package free function — the law's own home.
  function string h_free();
    int kf;
    h_free = "free";
    kf = h_free.len() - 1;
    h_free[0] = h_free[kf];
  endfunction

  // (H2) class IN-BODY method.
  class InB171;
    function string m_in();
      int ki;
      m_in = "inbody";
      ki = m_in.len() - 1;
      m_in[0] = m_in[ki];
    endfunction
  endclass

  // (H3) class OUT-OF-BODY method.
  class OutB171;
    extern function string m_out();
  endclass
  function string OutB171::m_out();
    int ko;
    m_out = "outbody";
    ko = m_out.len() - 1;
    m_out[0] = m_out[ko];
  endfunction
endpackage

package homes_clone_171;
  import homes_home_171::*;
  function int hc_use();
    InB171 hi;
    OutB171 ho;
    int rr;
    hi = new();
    ho = new();
    rr = h_free().len() + hi.m_in().len() + ho.m_out().len();
    return rr;
  endfunction
endpackage

interface homes_if_171;
  // (H4) INTERFACE function.
  function string i_fn();
    int kn;
    i_fn = "iface";
    kn = i_fn.len() - 1;
    i_fn[0] = i_fn[kn];
  endfunction
endinterface

module homes_child_171 #(parameter int WID = 1) ();
  import homes_clone_171::*;
  // (H5) MODULE function — includes the part-select family, which the corpus
  // only ever sees in a module function.
  function logic [15:0] m_fn();
    int km;
    km = 4;
    m_fn = 16'hface;
    m_fn[0]      = 1'b1;
    m_fn[7:4]    = 4'h9;
    m_fn[km +: 2] = 2'b01;
  endfunction
  int cr;
  initial cr = hc_use() + int'(m_fn()) + WID;
endmodule

module homes_top_171;
  homes_if_171 hif();
  homes_child_171 #(1) u1 ();
  homes_child_171 #(2) u2 ();
  homes_child_171 #(3) u3 ();
  int tr;
  initial tr = hif.i_fn().len();
endmodule
