// § hcSelIdxTsSkipsPort254 (the connection inside if, for and case generate scopes)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
  localparam int W = 2;
endpackage
module sub (input logic a);
endmodule
module top #(parameter int P = 1);
  import pk::*;
  logic [2:0] e;
  if (P == 1) begin : g_if
    sub u (.a(e[PMP_I]));
  end
  for (genvar k = 0; k < 2; k++) begin : g_for
    sub u (.a(e[PMP_D]));
  end
  case (P)
    1: begin : g_case sub u (.a(e[PMP_I])); end
    default: ;
  endcase
endmodule
