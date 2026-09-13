package p6;
  typedef struct packed {
    logic [1023:0] Wide;
    logic [7:0]    NrRules;
  } sub_t;
  typedef struct packed {
    logic [7:0] W;
    logic       Flag;
  } cfg_t;
  function automatic cfg_t build(sub_t u);
    cfg_t c;
    c.W    = 8'd5;
    c.Flag = (u.NrRules > 0) && (u.Wide > 0);
    return c;
  endfunction
  localparam sub_t U = '{Wide: 1024'(3), NrRules: 8'd2};
  localparam cfg_t CfgDefault = build(U);
endpackage
module child6 import p6::*; (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.Flag;
endmodule
module top6(output logic o);
  child6 u(.o(o));
endmodule
