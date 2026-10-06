// § genCaPsBoundOpChain254 (bounds that are calls: $clog2 and a user function, and a direct bound beside an operation bound)
module top #(parameter int W = 16) (input logic [15:0] a, output logic [3:0] o [1], output logic [3:0] p [1]);
  function automatic int h(int x); return x / 4; endfunction
  for (genvar k = 0; k < 1; k++) begin : g
    assign o[k] = a[$clog2(W)+3:$clog2(W)];
    assign p[k] = a[h(W)+3:h(W)];
  end
endmodule
