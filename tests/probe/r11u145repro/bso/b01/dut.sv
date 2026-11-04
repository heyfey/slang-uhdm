// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic p, output s_t o);
  localparam D = 2;
  s_t [D-1:0] sd;
  always_comb begin
    sd = '0;
    sd[D-1].v = p;
  end
  assign o = sd[0];
endmodule
