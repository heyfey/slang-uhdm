// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  always_comb y1 = q.f[{1'b0, signed'(k[1:0])}];
  assign o = y1;
endmodule
