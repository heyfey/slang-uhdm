// § unsignedScalarVecTsAtKeyword137
module top();
  logic unsigned [3:0] a;
  parameter logic unsigned [3:0] P = 4'd1;
  typedef enum logic unsigned [1:0] {A, B} e_t;
  e_t v;
endmodule
