// § packedArrTdElemRefName137
module sub();
  typedef enum logic [1:0] {A = 1, B = 2} e_t;
  typedef e_t [3:0] ea_t;
  ea_t v;
endmodule
module top();
  sub u1();
  sub u2();
endmodule
