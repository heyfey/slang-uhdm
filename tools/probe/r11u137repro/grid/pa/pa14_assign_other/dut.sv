// § packedArrTdElemRefName137
module top(output logic [7:0] o);
  typedef enum logic [1:0] {A = 1, B = 2} e_t;
  typedef e_t [3:0] ea_t;
  ea_t v;
  logic [7:0] w;
  assign w = 8'h3;
  assign o = v ^ w;
endmodule
