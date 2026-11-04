// § pkgElemMemberPatNoLoc152
package fp;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
typedef struct packed {
  fp::e_t [3:0] at;
  logic x;
} tf_t;
module top(input tf_t a, output tf_t b);
  assign b = a;
endmodule
