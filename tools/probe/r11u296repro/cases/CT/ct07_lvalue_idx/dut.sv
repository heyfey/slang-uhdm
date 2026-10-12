// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  st_t w;
  always_comb begin w = '0; w.f[{1'b1, 2'(k)}] = 1'b1; y1 = w.f[0]; end
  assign o = y1;
endmodule
