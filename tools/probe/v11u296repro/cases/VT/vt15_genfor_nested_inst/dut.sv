// § castTsInPathIdxByChain296
module leaf(input logic [7:0] k, output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  always_comb o = q.f[{1'b1, 2'(k)}];
endmodule
module dut(input logic [7:0] k, output logic [1:0] o);
  for (genvar g = 0; g < 2; g++) begin : gb
    leaf l (.k(k), .o(o[g]));
  end
endmodule
