// § pkgPatReadTsNoParent131
// case t01: a package pattern parameter member read qualified in a generate-for bound
package pk;
  typedef struct packed { logic [3:0] n; logic [3:0] w; } cfg_t;
  parameter cfg_t CFG = '{n: 4'd2, w: 4'd3};
endpackage
module top(input logic [1:0] a, output logic [1:0] y);
  for (genvar i = 0; i < pk::CFG.n; i++) begin : g
    assign y[i] = a[i];
  end
endmodule
