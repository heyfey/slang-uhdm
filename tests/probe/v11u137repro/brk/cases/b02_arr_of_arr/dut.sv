// § packedArrTdElemRefName137
module top(output logic o);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef e_t [1:0] ea_t;
  typedef ea_t [2:0] eaa_t;
  eaa_t v;
  assign o = v[0][0][0];
endmodule
