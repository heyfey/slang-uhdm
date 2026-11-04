// § pcwRefLastWriter250
// the package W used as a paren-cast width in an interface body and a generate scope
package p;
  parameter int W = 8;
  localparam logic [15:0] X = (W)'(16'h1ff);
endpackage
interface ifc;
  import p::*;
  logic [15:0] v;
  assign v = X;
endinterface
module top(output logic [15:0] y);
  import p::*;
  ifc i();
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam logic [15:0] Q = (W)'(g);
  end
  assign y = i.v ^ gb[1].Q;
endmodule
