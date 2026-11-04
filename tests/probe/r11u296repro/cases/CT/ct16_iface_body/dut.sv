// § castTsInPathIdxByChain296
interface ifb (input logic [3:0] k);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  logic y1;
  always_comb y1 = q.f[{1'b1, 2'(k)}];
endinterface
module dut(output logic o);
  logic [3:0] k;
  ifb b (.k(k));
  assign o = b.y1;
endmodule
