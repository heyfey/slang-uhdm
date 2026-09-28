// § pkgArrTdElemClone209
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef e_t [3:0] v_t;
endpackage
module top(output logic [1:0] o);
  q::v_t w;
  assign w[2] = q::B;
  assign o = w[2];
endmodule
