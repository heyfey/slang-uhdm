// § mdRenameNotUnderBareCa140v
package p;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import p::*; #(parameter logic [7:0][3:0] P = X, parameter int Z = 0) (output logic [31:0] o);
  assign o = P;
endmodule
module mid #(parameter int K = 1) (output logic [31:0] o); cc #(.Z(K)) u(.o(o)); endmodule
module top(output logic [31:0] o); mid #(.K(2)) m(.o(o)); endmodule
