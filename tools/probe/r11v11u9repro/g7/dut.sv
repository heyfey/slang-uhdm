package p7;
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
endpackage
module child7(output logic o);
  localparam p7::cfg_t Cfg = p7::build();
  assign o = Cfg.R;
endmodule
module top7(output logic o);
  child7 u(.o(o));
endmodule
