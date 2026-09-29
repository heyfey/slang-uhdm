// § hpLvSelIdxNamesByPath224 (the index an element of another path)
module top(input int j, input logic [1:0] d);
  typedef struct { logic [3:0] arr [4]; } s_t;
  typedef struct { int arr [4]; } t_t;
  s_t s; t_t t;
  always_comb s.arr[t.arr[j]][1:0] = d;
endmodule
