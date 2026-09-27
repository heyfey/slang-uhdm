// § importNetTsToInitEnd183 (an initializer from a macro abstains; a parenthesized initializer)
`define INIT 4'd5
package p;
  logic [3:0] a = `INIT;
  int b = (3 + 4);
endpackage
module top(output logic [3:0] o);
  import p::a;
  import p::b;
  assign o = a;
endmodule
