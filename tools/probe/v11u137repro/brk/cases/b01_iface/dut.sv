// § packedArrTdElemRefName137
interface bus;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t [3:0] ea_t;
  ea_t v;
endinterface
module top(output logic o);
  bus b();
  assign o = b.v[0][0];
endmodule
