// § sysCallKwTypeArgNameSpan131
// case s03: $bits(shortint) in a package parameter and an override actual
package p;
  parameter int PW = $bits(shortint);
endpackage
module sub #(parameter int P = 1) (output logic [7:0] o);
  assign o = P + p::PW;
endmodule
module top(output logic [7:0] o);
  sub #(.P($bits(byte))) u(.o(o));
endmodule
