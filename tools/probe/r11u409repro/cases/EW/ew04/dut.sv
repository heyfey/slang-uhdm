// § defImpArithSize32_409
module top;
  typedef enum bit [3:0] { A = 0, B = 2, C = 4 } e_t;
  parameter R = B;
  parameter S = B + C;
endmodule
