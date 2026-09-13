package p15;
  typedef struct packed {
    logic [7:0] W;
    logic       R;
    logic [3:0] K;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.W = 8'd5;
    c.R = 1'b1;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build();
endpackage
module child15 import p15::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.R;
endmodule
module top15(output logic o);
  child15 u(.o(o));
endmodule
