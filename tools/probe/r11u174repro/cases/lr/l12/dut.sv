// § elabParamLeftoverRefUnnamed174
package p;
  typedef struct packed {
    logic [7:0] A;
    bit         B;
  } cfg_t;
  function automatic cfg_t mk(logic [7:0] xa, bit xb);
    cfg_t c;
    c.A = xa;
    c.B = xb;
    return c;
  endfunction
  localparam cfg_t D = mk(8'hAB, 1'b1);
endpackage
module leaf #(parameter int unsigned W = 1) (); endmodule
module top #(parameter p::cfg_t Cfg = p::D) ();
  leaf #(.W(Cfg.A)) u();
endmodule
