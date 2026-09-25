// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic p, output logic o);
  localparam D = 2;
  s_t sd [D];
  always_comb begin
    sd[D-1].v = p;
    sd[D-1].r = '0;
    sd[0] = '0;
  end
  assign o = sd[D-1].v;
endmodule
