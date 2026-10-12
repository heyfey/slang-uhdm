// § castTsInPathIdxByChain296
class cw #(int W = 2);
endclass
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  always_comb y1 = q.f[{1'b1, 2'(cw#(3)::W)}];
  assign o = y1;
endmodule
