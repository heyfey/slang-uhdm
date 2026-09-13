package p18;
  typedef struct packed {
    logic [7:0] W;
    logic [7:0] X;
  } cfg_t;
  function automatic logic [7:0] half();
    return 8'd4;
  endfunction
  function automatic cfg_t build();
    cfg_t c;
    c.W = half();
    c.X = 8'd9;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build();
endpackage
module child18 import p18::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.W[0];
endmodule
module top18(output logic o);
  child18 u(.o(o));
endmodule
