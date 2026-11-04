// § clsLvTrailIdxNamesByChain310
typedef struct packed { logic [3:0][7:0] w; logic [7:0] v; } e_t;
module top(input logic [1:0] i, input logic [7:0] d, output e_t m);
  always_comb begin m.w[i + 1] = d; m.w[i] = d; m.w[int'(i)] = d; m.v = d; end
endmodule
