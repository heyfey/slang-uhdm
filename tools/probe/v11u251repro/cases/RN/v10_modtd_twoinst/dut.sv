// § regTdArrElabIsNet251 (a module-body reg typedef, the module instantiated twice)
module m;
  typedef reg r_t [3];
  r_t v;
endmodule
module top; m a(); m b(); endmodule
