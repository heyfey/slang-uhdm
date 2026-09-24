// § packedArrTdElemRefName137
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t [3:0] ea_t;
endpackage
module top(output logic o);
  import p::ea_t;
  ea_t v;
  assign o = v[1][0];
endmodule
