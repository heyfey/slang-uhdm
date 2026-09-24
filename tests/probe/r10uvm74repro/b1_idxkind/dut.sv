// r10uvm74 arm b1 — THE INDEX KIND on the BASE step of a BUILT-IN METHOD
// receiver path.  Every cell writes `<queue>[<index>].<builtin>()` so the ONLY
// thing that varies across the arm is what is inside the brackets.
//
// The head's own cell is `k_loopvar` (`arb_sequence_q[i].request.name()`
// reduced to its indexed step); `k_lit`/`k_lit0` are uvm-1.2's
// `split_val[2].len()` / `args[4].atoi()`; `k_strkey` is
// `m_streams[name].exists(...)`.
package p1;
  class holder;
    string s;
    int    v;
    function string get(); return s; endfunction
  endclass
endpackage

module b1;
  import p1::*;

  localparam int P = 3;

  class user;
    string  sq[$];
    string  saa[string];
    holder  cq[$];
    int     iq[$];

    function void f(string key, int j);
      int    r_loopvar, r_lit, r_lit0, r_param, r_expr, r_strkey, r_argmeth;
      string t_sub;
      foreach (sq[i]) begin
        r_loopvar = sq[i].len();          // cell k_loopvar
        t_sub     = sq[i].substr(0, 1);   // cell k_argmeth (method WITH args)
      end
      r_lit    = sq[2].len();             // cell k_lit
      r_lit0   = sq[0].len();             // cell k_lit0
      r_param  = sq[P].len();             // cell k_param
      r_expr   = sq[j + 1].len();         // cell k_expr
      r_strkey = saa[key].len();          // cell k_strkey
      r_argmeth = r_lit + r_lit0 + r_param + r_expr + r_strkey + r_loopvar;
      if (t_sub == "") r_argmeth = 0;
    endfunction

    // cell k_deep — the HEAD's exact written shape: indexed base, a MEMBER
    // step, then the built-in method.
    function string g();
      return cq[0].s.substr(0, 1);
    endfunction

    // cell k_nonbase — the index on a NON-base step.
    function int h(holder hh);
      return hh.s.len();
    endfunction
  endclass

  user u;
  initial begin
    u = new();
    u.f("k", 1);
  end
endmodule
