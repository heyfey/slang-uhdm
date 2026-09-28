// § genForWholeLhsNestedKeep192v § psBoundPaOwnerName192 § genForReplCountOwner192
package p;
  parameter int unsigned W = 4;
endpackage
module sub import p::*; (input logic c, input logic [31:0] x, output logic [31:0] z1, output logic [31:0] z2, output logic [31:0] z3, output logic [31:0] z4, output logic [31:0] z5, output logic z6);
  function automatic logic [31:0] id(input logic [31:0] a); return a; endfunction
  for (genvar i = 0; i < 1; i++) begin : g
    assign z1 = c ? x[W:0] : 32'd0;
    assign z2 = -x[W:0];
    assign z3 = id(x[W:0]);
    assign z4 = $unsigned(x[W:0]);
    assign z5 = {W{x[0]}} + 32'd0;
    assign z6 = &x[W:0];
  end
endmodule
module top (input logic c, input logic [31:0] x, output logic [31:0] z1, output logic [31:0] z2, output logic [31:0] z3, output logic [31:0] z4, output logic [31:0] z5, output logic z6);
  sub u (.*);
endmodule
