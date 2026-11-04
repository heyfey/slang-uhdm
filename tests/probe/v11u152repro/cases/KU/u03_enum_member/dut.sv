// § pkgElemMemberPatNoLoc152
package fp;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
typedef struct packed {
  fp::e_t [2:0] es;
} tf_t;
module top(input tf_t a, output tf_t b);
  assign b = a;
endmodule
