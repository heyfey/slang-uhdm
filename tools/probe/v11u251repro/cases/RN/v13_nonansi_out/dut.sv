// § regTdArrElabIsNet251 (non-ANSI output declared then typed by a reg typedef)
typedef reg r_t [2];
module child(o);
  output r_t o;
endmodule
module top; logic [1:0] w; child c(); endmodule
