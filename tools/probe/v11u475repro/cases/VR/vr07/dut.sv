// § elabImpRefDecRespell475
// an interface and a child module reading an imported chain
package a;
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = PA;
endpackage
interface ifc;
  import a::*;
  logic [5:0] y;
  assign y = PB;
endinterface
module sub(output logic [5:0] y);
  import a::*;
  assign y = PB;
endmodule
module top(output logic [5:0] y);
  ifc i();
  sub u(y);
endmodule
