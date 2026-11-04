// § castTsInPathIdxByChain296
`define CI(x) 3'(x)
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; logic [7:0] k;
  assign o = q.f[`CI(k)];
endmodule
