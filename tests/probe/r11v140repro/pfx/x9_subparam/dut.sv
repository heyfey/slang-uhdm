// § mdRenameNotUnderBareCa140v
package p;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import p::*; #(parameter logic [7:0][3:0] P = X) ();
  sub #(.Q(P)) s();
endmodule
module sub #(parameter logic [31:0] Q = 0) (); endmodule
module top; cc u(); endmodule
