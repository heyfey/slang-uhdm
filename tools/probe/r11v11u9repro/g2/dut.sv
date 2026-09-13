package p2;
  typedef struct packed {
    logic [7:0] W;
    logic       R;
    logic [3:0] K;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.W = 8'd5;
    c.R = 1'b1;
    c.K = 4'h3;
    return c;
  endfunction
  localparam cfg_t CfgDefault = build();
endpackage
module child2(output logic o);
  import p2::CfgDefault;
  import p2::cfg_t;
  localparam cfg_t L = CfgDefault;
  assign o = L.R;
endmodule
module top2(output logic o);
  child2 u(.o(o));
endmodule
