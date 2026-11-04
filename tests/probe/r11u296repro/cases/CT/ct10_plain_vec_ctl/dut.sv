// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  logic [31:0] v;
  always_comb y1 = v[{1'b1, 2'(k)}];
  assign o = y1;
endmodule
