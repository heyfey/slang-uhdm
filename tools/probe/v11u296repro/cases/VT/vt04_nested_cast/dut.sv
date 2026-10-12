// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [7:0] k;
  assign o = q.f[2'(3'(k))];
endmodule
