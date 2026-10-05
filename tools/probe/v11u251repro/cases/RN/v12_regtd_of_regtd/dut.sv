// § regTdArrElabIsNet251 (control: the outer typedef aliases a reg typedef, not the keyword)
typedef reg [1:0] e_t;
typedef e_t r_t [2];
module top; r_t m; endmodule
