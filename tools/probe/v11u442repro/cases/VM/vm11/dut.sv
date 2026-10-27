// § modDynArrClsTdElemClassVar442
class C;
endclass
module top;
  typedef C c_t;
  c_t q [$];
  c_t d [];
  c_t a [string];
endmodule
