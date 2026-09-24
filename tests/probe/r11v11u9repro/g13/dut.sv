package p13;
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
module child13 #(parameter p13::cfg_t Cfg = p13::CfgDefault) (output logic o);
  assign o = Cfg.R;
endmodule
module top13(output logic [1:0] o);
  child13 u0(.o(o[0]));
  child13 #(.Cfg(p13::CfgDefault)) u1(.o(o[1]));
endmodule
