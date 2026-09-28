// § pdTsNotTypedefListing209v — r11u217 p04: a non-ANSI interface port declared with a typedef (`input my_t a;`), a port declared plain then REDECLARED with a package typedef (`input [7:0] b; p::w_t b;`), and a plain ranged port beside them; the typedefs read by the module too
package p;
  typedef logic [7:0] w_t;
endpackage
typedef logic [3:0] my_t;
interface ifc (a, b, c);
  input my_t a;
  input [7:0] b;
  p::w_t b;
  input logic [3:0] c;
  logic [3:0] w;
  assign w = a ^ b[3:0] ^ c;
endinterface
module top (input my_t i, input p::w_t j, output logic [3:0] y);
  my_t z;
  assign z = i;
  ifc u (.a(z), .b(j), .c(i));
  assign y = u.w;
endmodule
