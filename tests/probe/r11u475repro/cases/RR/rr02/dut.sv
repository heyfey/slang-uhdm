// § elabImpRefDecRespell475
// octal and binary chains, two hops, in a child instance
package a;
  parameter logic [5:0] PO = 6'o41;
  parameter logic [5:0] PO2 = PO;
  parameter logic [5:0] PO3 = PO2;
  parameter logic [3:0] PBN = 4'b1010;
  parameter logic [3:0] PB2 = PBN;
endpackage
module sub(output logic [5:0] y, output logic [3:0] z);
  import a::*;
  assign y = PO3;
  assign z = PB2;
endmodule
module top(output logic [5:0] y, output logic [3:0] z);
  sub u(.y(y), .z(z));
endmodule
