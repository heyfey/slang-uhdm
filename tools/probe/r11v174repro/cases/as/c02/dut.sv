// § asmRefQualWholeSpanElab174
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = x;
    c.B = y;
    c.C = 7;
    return c;
  endfunction
  localparam cfg_t D = mk(64, 5);
endpackage
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
`define CF p::D
module top #(parameter p::cfg_t Cfg = `CF /* c */) ();
  leaf #(.W(Cfg.A)) u();
endmodule
