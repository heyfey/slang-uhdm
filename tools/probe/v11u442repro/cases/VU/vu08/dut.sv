// § unitArrTdAliasVarBindsListing442
typedef int ua_t [2];
typedef ua_t ub_t;
interface ifc;
  typedef logic [2:0] ub_t [5];
  ub_t iv;
endinterface
module top;
  ifc i();
endmodule
