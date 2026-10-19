// § unitAssocTdMultiDim406
typedef int t2 [3][$];
module top;
  t2 v;
  initial v[0].push_back(1);
endmodule
