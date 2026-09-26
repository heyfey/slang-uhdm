// § elabParamLeftoverRefUnnamed174
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
  } cfg_t;
  function automatic cfg_t mk(int unsigned x);
    cfg_t c;
    c.A = x;
    c.B = x + 1;
    return c;
  endfunction
endpackage
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1) (); endmodule
module top #(parameter int unsigned N = 6, parameter p::cfg_t Cfg = p::mk(N)) ();
  leaf #(.W(Cfg.A), .V(Cfg.B)) u();
endmodule
