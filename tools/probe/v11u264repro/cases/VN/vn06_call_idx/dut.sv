// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [7:0] en; } s_t;
module top(input logic [7:0] a, output s_t w);
  function automatic int f(int x); return x + 1; endfunction
  localparam int P = 2;
  for (genvar k = 0; k < 3; k++) begin : g
    assign w.en[f(k)] = a[k];
  end
  assign w.en[$clog2(P)+5] = 1'b0;
  assign w.en[7] = a[7];
  assign w.en[0] = a[0];
endmodule
