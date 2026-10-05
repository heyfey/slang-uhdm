// § clsTdUnionBuilt237
// two classes, same union name; one in the second file of a CRLF source
package p;
class a;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
  u_t m;
endclass
class b;
  typedef union packed { logic [15:0] x; bit [15:0] y; } u_t;
  u_t m;
endclass
endpackage
module top;
endmodule
