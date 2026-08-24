// v119 arm M — MACRO SURFACES that could defeat a positional or textual fence.
// The scope form and the member form are both written through macros here, so
// if the two predicates can ever both fire (or both refuse) this arm shows it.
`define SCOPE_M(C)   if (!randomize() with C) m_out = m_out + 1;
`define SCOPEARG_M(N, C) if (!randomize(N) with C) m_out = m_out + 2;
`define RECVNAME_M   r_m
`define WHOLE_M(R, C) if (!R.randomize() with C) m_out = m_out + 4;
`define STD_M(V)     if (!std::randomize(V)) m_out = m_out + 8;

class it_m;
  rand int unsigned m_v;
  rand int unsigned m_w;
endclass

class drv_m;
  rand int unsigned s_v;
  rand int unsigned s_w;
  it_m r_m;
  it_m other_m;
  int unsigned m_out;
  task run_m();
    int unsigned l_m;
    // the SCOPE form, written entirely inside a macro
    `SCOPE_M({ s_v > 1; })
    // the SCOPE form with an identifier list, macro-written
    `SCOPEARG_M(s_w, { s_w > 2; })
    // the MEMBER form whose RECEIVER is itself a macro
    if (!`RECVNAME_M.randomize() with { m_v > 3; }) m_out = m_out + 16;
    // the MEMBER form written entirely inside a macro, receiver as an argument
    `WHOLE_M(other_m, { m_w > 4; })
    // std::randomize inside a macro
    `STD_M(l_m)
    // and the plain written twins of each, for a same-file comparison
    if (!randomize() with { s_v > 5; }) m_out = m_out + 32;
    if (!r_m.randomize() with { m_v > 6; }) m_out = m_out + 64;
  endtask
endclass

module top_m;
  drv_m d_m;
  initial begin
    d_m = new();
    d_m.run_m();
  end
endmodule
