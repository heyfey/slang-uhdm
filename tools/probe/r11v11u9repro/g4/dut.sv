package p4;
  typedef struct packed {
    logic [15:0][63:0] BIG;
    logic [7:0]        W;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.BIG = {16{64'hDEAD_BEEF_0000_0001}};
    c.W   = 8'd9;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build();
endpackage
module child4 import p4::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.W[0];
endmodule
module top4(output logic o);
  child4 u(.o(o));
endmodule
