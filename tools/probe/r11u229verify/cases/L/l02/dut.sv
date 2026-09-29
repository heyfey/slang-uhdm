// § hpLvSelIdxNamesByPath224 (a nonblocking assignment in an always_ff of a for-generate, the index the genvar)
module top(input logic c, input logic [1:0] d);
  typedef struct { logic [3:0] arr [4]; } s_t;
  s_t s;
  for (genvar g = 0; g < 2; g++) begin : gb
    always_ff @(posedge c) s.arr[g][1:0] <= d;
  end
endmodule
