// § genForWholeLhsNestedKeep192v § psBoundPaOwnerName192 § genForReplCountOwner192
package p;
  parameter int unsigned W = 4;
endpackage
module sub import p::*; (input logic c, input logic [31:0] x, output logic [31:0] z);
  function automatic logic [31:0] id(input logic [31:0] a); return a; endfunction
  for (genvar i = 0; i < 1; i++) begin : g
    assign z = $countones({1'b0, x[W:0]});
  end
endmodule
module top (input logic c, input logic [31:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
