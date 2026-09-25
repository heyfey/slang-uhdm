// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
module dut(input logic [1:0] i, input logic p, output logic o);
  s_t sd [4][2];
  always_comb begin
    sd = '{default: '0};
    sd[i+1][0].v = p;
  end
  assign o = sd[1][0].v;
endmodule
