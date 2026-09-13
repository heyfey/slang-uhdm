package p11;
  typedef struct packed {
    logic [31:0] X;
    logic [31:0] Y;
  } sub_t;
  typedef struct packed {
    sub_t       U;
    logic [7:0] W;
  } cfg_t;
  function automatic sub_t bu();
    sub_t u;
    u.X = 32'd3;
    u.Y = 32'd4;
    return u;
  endfunction
  localparam sub_t UCFG = bu();
  function automatic cfg_t build(sub_t uu);
    cfg_t c;
    c.U = uu;
    c.W = 8'd5;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build(UCFG);
endpackage
module child11 import p11::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.W[0];
endmodule
module top11(output logic o);
  child11 u(.o(o));
endmodule
