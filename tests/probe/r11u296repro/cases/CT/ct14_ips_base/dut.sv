// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  logic [1:0] p2;
  always_comb begin p2 = q.f[{1'b0, 2'(k)} +: 2]; y1 = p2[0]; end
  assign o = y1;
endmodule
