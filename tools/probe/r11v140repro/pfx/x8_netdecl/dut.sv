// § mdRenameNotUnderBareCa140v
package p;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import p::*; #(parameter logic [7:0][3:0] P = X) ();
  wire [31:0] w = P;
endmodule
module top; cc u(); endmodule
