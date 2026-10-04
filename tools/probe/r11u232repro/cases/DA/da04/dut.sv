// § defAggParamBindsImportClone232
package p;
  typedef struct {
    int a;
    int b;
  } ucfg_t;
endpackage
module top(output int o);
  import p::*;
  parameter ucfg_t U = '{a: 1, b: 2};
  assign o = U.b;
endmodule
