package p12;
  typedef struct packed {
    logic [7:0] W;
    logic       R;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.W = 8'd5;
    c.R = 1'b1;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build();
endpackage
module child12 import p12::*; #(parameter int N = 0) (output logic o);
  localparam cfg_t L = CfgDefault;
  assign o = L.R ^ N[0];
endmodule
module top12(output logic [2:0] o);
  child12 #(.N(0)) u0(.o(o[0]));
  child12 #(.N(1)) u1(.o(o[1]));
  child12 #(.N(2)) u2(.o(o[2]));
endmodule
