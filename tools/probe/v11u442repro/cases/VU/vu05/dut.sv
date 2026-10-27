// § unitArrTdAliasVarBindsListing442
typedef int ua_t [2];
typedef ua_t ub_t;
module top;
  ub_t v;
  generate if (1) begin : g
    ub_t gv;
  end endgenerate
endmodule
