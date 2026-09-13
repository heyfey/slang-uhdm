package p10;
  localparam int unsigned XLEN = 64;
  typedef struct packed {
    logic [31:0] V;
    logic [7:0]  W;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.V = XLEN;
    c.W = 8'd5;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build();
endpackage
module child10 import p10::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.W[0];
endmodule
module top10(output logic o);
  child10 u(.o(o));
endmodule
