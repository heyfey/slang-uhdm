package p16;
  typedef enum {
    ModeA,
    ModeB
  } vm_mode_t;
  typedef struct packed {
    logic [7:0] W;
    vm_mode_t   MODE;
  } user_t;
  typedef struct packed {
    logic [7:0] W;
    vm_mode_t   MODE;
  } cfg_t;
  function automatic cfg_t build(user_t u);
    cfg_t c;
    c.W    = u.W;
    c.MODE = u.MODE;
    return c;
  endfunction
  localparam user_t UCFG = '{
      W: 8'd5,
      MODE: ModeB
  };
  localparam cfg_t CfgDefault = build(UCFG);
endpackage
module child16 import p16::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.W[0];
endmodule
module top16(output logic o);
  child16 u(.o(o));
endmodule
