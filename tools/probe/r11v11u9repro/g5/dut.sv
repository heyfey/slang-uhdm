package p5;
  typedef enum { EA, EB } e_t;
  typedef struct packed {
    logic [7:0] W;
    logic       R;
  } sub_t;
  typedef struct packed {
    logic [7:0] W;
    logic       R;
  } cfg_t;
  function automatic cfg_t build(sub_t u);
    cfg_t c;
    c.W = u.W;
    c.R = u.R;
    return c;
  endfunction
  localparam sub_t U = '{W: EA, R: 1'b1};
  localparam cfg_t CfgDefault = build(U);
endpackage
module child5 import p5::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.R;
endmodule
module top5(output logic o);
  child5 u(.o(o));
endmodule
