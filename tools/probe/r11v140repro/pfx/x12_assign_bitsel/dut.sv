// § mdRenameNotUnderBareCa140v
package p;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import p::*; #(parameter logic [7:0][3:0] P = X) (output logic [3:0] o);
  assign o = P[1];
endmodule
module top(output logic [3:0] o); cc u(.o(o)); endmodule
