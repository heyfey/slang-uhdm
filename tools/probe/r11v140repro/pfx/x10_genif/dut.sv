// § mdRenameNotUnderBareCa140v
package p;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import p::*; #(parameter logic [7:0][3:0] P = X) ();
  if (P[0] == 4'hd) begin : g
    logic w;
  end
endmodule
module top; cc u(); endmodule
