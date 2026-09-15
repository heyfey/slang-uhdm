// g10 — the SUPPRESSING direction's negative control: a call argument bound to
// a MODULE-level variable (not a subroutine body local).  Surelog emits it as
// a net, and golden STAMPS it — the guard must not reach here.
module g10 (input logic clk, output int unsigned o);
  logic [3:0] v;
  function automatic int unsigned w(logic [3:0] i); return i + 1; endfunction
  assign o = w(v);
endmodule
