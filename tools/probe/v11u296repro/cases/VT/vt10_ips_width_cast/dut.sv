// § castTsInPathIdxByChain296
module dut(output logic [3:0] o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [7:0] k;
  assign o = q.f[3'(k) +: 4];
endmodule
