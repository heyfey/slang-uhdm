// § hpLvSelIdxNamesByPath224 (the index a cast)
module top(input int k, input logic [1:0] d);
  typedef struct { logic [3:0] arr [4]; } s_t;
  s_t s;
  always_comb s.arr[int'(k)][1:0] = d;
endmodule
