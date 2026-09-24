// § mdRenameNotUnderBareCa140v
package p;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc #(parameter int W = 1) (output logic [31:0] o);
  import p::*;
  localparam logic [7:0][3:0] P = X;
  assign o = P;
endmodule
module top(output logic [31:0] o); cc u(.o(o)); endmodule
