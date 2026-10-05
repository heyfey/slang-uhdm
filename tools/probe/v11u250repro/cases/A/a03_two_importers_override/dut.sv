// § pcwOtherSymKeeps250v
// two modules import the package; one has a parameter port of the same name overridden at its instance
package p;
  parameter int W = 8;
  localparam int unsigned X = (W)'(300);
endpackage
module sub #(parameter int W = 5) (output logic [7:0] o);
  localparam int unsigned Y = (W)'(255);
  assign o = Y[7:0];
endmodule
module mid(output logic [15:0] y);
  import p::*;
  assign y = X[15:0];
endmodule
module top(output logic [15:0] y, output logic [7:0] o1, o2);
  mid m(.y(y));
  sub #(.W(2)) u1(.o(o1));
  sub u2(.o(o2));
endmodule
