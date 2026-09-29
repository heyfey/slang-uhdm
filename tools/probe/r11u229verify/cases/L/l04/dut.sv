// § hpLvSelIdxNamesByPath224 (the index a system call on a parameter)
module top #(parameter int N = 4) (input logic [1:0] d);
  typedef struct { logic [3:0] arr [4]; } s_t;
  s_t s;
  always_comb s.arr[$clog2(N)][1:0] = d;
endmodule
