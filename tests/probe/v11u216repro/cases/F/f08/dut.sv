// § genScopeRangeQueryFold216 — $high of a package-qualified bound in a gen-for, onto a module net
package pk;
  parameter int W = 6;
endpackage
module top (input logic [pk::W-1:0] i, output logic [7:0] c);
  for (genvar k = 0; k < 1; k++) begin : g
    assign c = $high(i);
  end
endmodule
