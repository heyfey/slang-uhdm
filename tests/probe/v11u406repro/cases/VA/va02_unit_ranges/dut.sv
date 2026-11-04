// § unitAssocTdMultiDim406
typedef logic [3:0] t2 [0:1][4];
module top;
  t2 v;
  initial v[1][2] = 4'h3;
endmodule
