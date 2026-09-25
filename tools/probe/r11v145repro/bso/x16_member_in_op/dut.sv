// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
typedef struct packed { logic [1:0] ix; } c_t;
module dut(input s_t [3:0] sd, input c_t c, output logic o);
  assign o = sd[c.ix + 1].v;
endmodule
