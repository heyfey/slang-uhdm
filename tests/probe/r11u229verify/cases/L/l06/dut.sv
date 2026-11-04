// § hpLvSelIdxNamesByPath224 (the element select in the middle of the path, a member after it)
module top(input int i, input logic [1:0] d);
  typedef struct { logic [3:0] m; } e_t;
  typedef struct { e_t arr [4]; } s_t;
  s_t s;
  always_comb s.arr[i].m[1:0] = d;
endmodule
