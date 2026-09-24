// § packedArrTdElemRefName137
interface ifc();
  typedef enum logic [1:0] {A = 1, B = 2} e_t;
  typedef e_t [3:0] ea_t;
  ea_t v;
endinterface
module top();
  ifc u();
endmodule
