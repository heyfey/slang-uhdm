// § clsLvTrailIdxNamesByChain310
typedef struct packed { logic [3:0][7:0] w; logic [7:0] v; } e_t;
module top(input logic clk, input logic [1:0] i, input logic [7:0] d, output e_t m);
  function automatic int fn(int x); return x; endfunction
  always_ff @(posedge clk) begin m.w[i + 1] <= d; m.w[fn(i)] <= d; m.v <= d; end
endmodule
