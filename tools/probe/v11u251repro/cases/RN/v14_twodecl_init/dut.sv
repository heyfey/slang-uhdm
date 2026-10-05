// § regTdArrElabIsNet251 (two declarators, one with an initializer)
typedef reg r_t [2];
module top;
  r_t a, b = '{1'b0, 1'b1};
endmodule
