// § enumDefOwnerNotInstance191: an imported enum used by two definitions each instantiated twice
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module zz; import p::*; e_t z; endmodule
module aa; import p::*; e_t a; endmodule
module top;
  aa u1(); aa u2();
  zz v1(); zz v2();
endmodule
