// § packedArrTdElemRefName137
package p;
  typedef enum logic [1:0] {A = 1, B = 2} e_t;
  typedef e_t [3:0] ea_t;
endpackage
module top();
  p::ea_t v;
endmodule
