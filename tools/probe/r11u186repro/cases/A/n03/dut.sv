// § assocPromotedBoundAtBracket183
package p;
typedef enum {A, B} e_t;
task automatic t();
  string m[e_t];
  m[A] = "a";
endtask
endpackage
module top; endmodule
