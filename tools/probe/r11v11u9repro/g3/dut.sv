package p3;
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
module child3(output logic o);
  localparam p3::cfg_t L = p3::CfgDefault;
  assign o = L.R;
endmodule
module top3(output logic o);
  child3 u(.o(o));
endmodule
