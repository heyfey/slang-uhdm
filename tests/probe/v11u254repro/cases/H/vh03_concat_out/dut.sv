// § hcSelIdxTsSkipsPort254 (a concatenation of imported-index selects, an output port and an inout port)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
module sub (input logic [1:0] a, output logic o, inout wire io);
endmodule
module top;
  import pk::*;
  logic [2:0] e;
  logic [2:0] f;
  wire [2:0] w;
  sub u (.a({e[PMP_I], e[PMP_D]}), .o(f[PMP_D]), .io(w[PMP_I]));
endmodule
