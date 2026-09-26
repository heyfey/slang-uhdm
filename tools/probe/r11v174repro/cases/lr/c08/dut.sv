// § elabParamLeftoverRefUnnamed174
package p;
  typedef struct {
    int unsigned A;
    int unsigned B;
  } ucfg_t;
  function automatic ucfg_t mk(int unsigned x, int unsigned y);
    ucfg_t c;
    c.A = x;
    c.B = y;
    return c;
  endfunction
  localparam ucfg_t D = mk(64, 5);
endpackage
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1) (); endmodule
module top #(parameter p::ucfg_t Cfg = p::D) ();
  leaf #(.W(Cfg.A), .V(Cfg.B)) u();
endmodule
