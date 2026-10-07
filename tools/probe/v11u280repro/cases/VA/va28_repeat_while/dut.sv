// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// the path in a repeat count, a do-while condition and a return of a function in a generate
module top(input logic [1:0] k, output logic [3:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic [1:0] b; } s_t;
  s_t z;
  assign z = '0;
  for (genvar i = 0; i < 2; i++) begin : gf
    function automatic logic f(logic [1:0] kk); return z.g[kk][i]; endfunction
    assign o[i] = f(k);
  end
  initial begin
    repeat (z.g[k][1]) o[2] = 1'b0;
    do o[3] = 1'b1; while (z.g[k][0]);
  end
endmodule
