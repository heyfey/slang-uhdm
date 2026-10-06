// § hcSelIdxTsSkipsPort254 (fresh: an interface instantiated inside an interface body through a select indexed by an imported parameter, a generate-local net, an implicit-net neighbour)
package pk;
  parameter int unsigned PMP_I = 0;
endpackage
interface inner (input logic a);
endinterface
interface outer import pk::*; (input logic [2:0] e);
  inner ii (.a(e[PMP_I]));
endinterface
module sub (input logic a, input logic b);
endmodule
module top #(parameter int P = 1);
  import pk::*;
  logic [2:0] e;
  outer o (.e(e));
  if (P == 1) begin : g
    logic [2:0] gl;
    sub u (.a(gl[PMP_I]), .b(imp));
  end
endmodule
