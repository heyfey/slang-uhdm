// § modDynArrClsTdElemClassVar442
class C;
endclass
typedef C uc_t;
interface ifc;
  uc_t q [$];
endinterface
module top;
  ifc i();
  uc_t d [];
endmodule
