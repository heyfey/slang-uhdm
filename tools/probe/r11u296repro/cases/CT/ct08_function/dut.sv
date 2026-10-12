// § castTsInPathIdxByChain296
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  function automatic logic fz(input st_t s, input logic [3:0] kk); return s.f[{1'b1, 2'(kk)}]; endfunction
  always_comb y1 = fz(q, k);
  assign o = y1;
endmodule
