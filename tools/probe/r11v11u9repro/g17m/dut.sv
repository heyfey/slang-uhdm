package p17;
  typedef struct packed {
    logic [1023:0] Wide;
    logic [7:0]    W;
  } user_t;
  typedef struct packed {
    logic [1023:0] Wide;
    logic [7:0]    W;
  } cfg_t;
  function automatic cfg_t build(user_t u);
    cfg_t c;
    c.Wide = u.Wide;
    c.W    = u.W;
    return c;
  endfunction
  localparam user_t UCFG = '{
      Wide: 1024'(64'hDEAD_BEEF),
      W: 8'd7
  };
endpackage
module child17 import p17::*; (output logic o);
  localparam cfg_t CfgDefault = build(UCFG);
  assign o = CfgDefault.W[0];
endmodule
module top17(output logic o);
  child17 u(.o(o));
endmodule
