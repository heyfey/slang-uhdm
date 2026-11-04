// § mdRenameNotUnderBareCa140v
package p;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import p::*; #(parameter logic [7:0][3:0] P = X) ();
  localparam logic [31:0] Q = P;
endmodule
module top; cc u(); endmodule
