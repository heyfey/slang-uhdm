// § unitAssocTdMultiDim406
typedef shortint t2 [4][2];
module child;
  t2 w;
endmodule
module top;
  t2 v;
  child c();
endmodule
