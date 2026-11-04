// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [2:0] t3_t;
  st_t q; logic [7:0] k;
  always_comb o = q.f[t3_t'(k) + t3_t'(1)];
endmodule
