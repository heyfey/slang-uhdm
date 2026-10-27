// § unitArrTdAliasVarBindsListing442
typedef int ua_t [2];
typedef ua_t ub_t;
module top;
  generate if (1) begin : g
    typedef byte ub_t [3];
    ub_t gv;
  end endgenerate
endmodule
