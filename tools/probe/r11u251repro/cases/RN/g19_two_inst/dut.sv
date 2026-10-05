// § regTdArrElabIsNet251
typedef reg [3:0] f_t[4];
typedef reg d_t[];
module m; logic a; f_t x; d_t d; endmodule
module top; m u1(); m u2(); endmodule
