// § unitArrTdAliasVarBindsListing442
typedef logic [3:0] ua_t [2];
typedef ua_t ub_t;
interface ifc;
  ub_t v;
endinterface
module top;
  ifc i();
  ub_t w [3];
endmodule
