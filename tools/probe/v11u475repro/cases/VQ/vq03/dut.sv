// § pkgQualCaReadValueForm475
// a parenthesized qualified read and a qualified read in a generate block
package p;
  parameter logic [5:0] P = 6'd33;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  assign y = (p::P);
  if (1) begin : g
    assign z = p::P;
  end
endmodule
