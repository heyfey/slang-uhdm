// § unitAssocTdMultiDim406
module child #(parameter N = 2);
  typedef int t2 [N][2];
  t2 v;
endmodule
module top;
  child #(2) c1();
  child #(3) c2();
endmodule
