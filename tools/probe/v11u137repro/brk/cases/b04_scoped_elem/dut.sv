// § packedArrTdElemRefName137
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
module top(output logic o);
  typedef p::e_t [3:0] ea_t;
  ea_t v;
  assign o = v[1][0];
endmodule
