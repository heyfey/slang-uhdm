// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a task with an output argument reading the path and a static function
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  assign z = '0;
  task automatic t(output logic r); r = z.g[k][1]; endtask
  function static logic f(); return z.g[k][0]; endfunction
  always_comb begin logic r; t(r); o = r ^ f(); end
endmodule
