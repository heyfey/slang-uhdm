// § suSigningNotInSpan130
package pkg;
  struct packed signed { logic [3:0] a; logic [3:0] b; } pv;
endpackage
module top(output logic [7:0] o);
  assign o = pkg::pv;
endmodule
