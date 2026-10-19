// § unitAssocTdMultiDim406
module top;
  parameter k = 3;
  typedef bit d_t;
  typedef d_t a_t [bit[k:0]][int];
  typedef int b_t [2][3];
  typedef int c_t [int][string];
endmodule
