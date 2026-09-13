package p8;
  typedef struct packed {
    logic [7:0] A;
    logic [3:0] B;
  } inner_t;
  typedef struct packed {
    inner_t     I;
    logic [7:0] W;
  } cfg_t;
  function automatic inner_t bi();
    inner_t i;
    i.A = 8'd7;
    i.B = 4'd2;
    return i;
  endfunction
  localparam inner_t IN = bi();
  function automatic cfg_t build(inner_t ii);
    cfg_t c;
    c.I = ii;
    c.W = 8'd9;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build(IN);
endpackage
module child8 import p8::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.W[0];
endmodule
module top8(output logic o);
  child8 u(.o(o));
endmodule
