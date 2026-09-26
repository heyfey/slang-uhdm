// § memLeftSliceUnlocated169
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = x;
    c.B = x / 8;
    c.C = 7;
    return c;
  endfunction
endpackage
module top #(parameter int unsigned W = 64, parameter p::cfg_t Cfg = p::mk(W, 5)) ();
  leaf #(.W(Cfg.A), .V(Cfg.B), .U(Cfg.C)) u();

endmodule
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
