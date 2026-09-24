// § packedArrTdElemRefName137
module top #(parameter int W = 4)();
  typedef enum logic [1:0] {A = 1, B = 2} e_t;
  typedef e_t [W-1:0] ea_t;
  ea_t v;
endmodule
