// § regTdArrElabIsNet251 (a static-qualified module variable of a reg typedef)
typedef reg r_t [2];
module top;
  static r_t m;
endmodule
