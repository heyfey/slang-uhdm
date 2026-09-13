package p9;
  typedef enum logic [1:0] { EA = 2'd0, EB = 2'd1 } e_t;
  typedef struct packed {
    e_t         E;
    logic [7:0] W;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.E = EB;
    c.W = 8'd5;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build();
endpackage
module child9 import p9::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.W[0];
endmodule
module top9(output logic o);
  child9 u(.o(o));
endmodule
