// § regTdArrElabIsNet251 (a non-ANSI output port whose type comes from a separate data declaration)
typedef reg r_t [2];
module child(o);
  output o;
  r_t o;
endmodule
module top; child c(); endmodule
