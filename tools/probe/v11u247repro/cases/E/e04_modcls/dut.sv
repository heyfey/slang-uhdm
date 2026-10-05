// § clsPropElemAliasName247
typedef int ut_t;
module top;
  typedef bit [3:0] mt_t;
  class q;
    ut_t uq[$];
    mt_t md[];
    ut_t ua[string];
  endclass
  q x;
endmodule
