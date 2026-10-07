// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280
// rvalue member two selects inside a task
module top(input logic [1:0] k, output logic o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  s_t z;
  logic r;
  task automatic t(input logic [1:0] i);
    r = z.g[i][0];
  endtask
  assign z = '0;
  initial t(k);
  assign o = r;
endmodule
