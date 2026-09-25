// § mdRenameNotUnderBareCa140v
package aes_pkg;
  parameter logic [7:0][3:0] X = 32'habcd;
endpackage
module cc import aes_pkg::*; #(parameter logic [7:0][3:0] P = X, parameter logic Z = 0) (output logic [31:0] o);
  assign o = ~P;
endmodule
module top(output logic [31:0] o);
  cc #(.Z(1)) u(.o(o));
endmodule
