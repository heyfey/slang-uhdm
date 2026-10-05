// § pcwOtherSymKeeps250v
// a module's own parameter W, used as a paren-cast width, shares its name with a package parameter W used the same way
package p;
  parameter int W = 8;
  localparam logic [15:0] X = (W)'(16'h1ff);
endpackage
module sub #(parameter int W = 4) (output logic [7:0] o);
  assign o = 8'((W)'(8'hff));
endmodule
module top(output logic [15:0] y, output logic [7:0] o);
  import p::*;
  assign y = X;
  sub u(.o(o));
endmodule
