// § regTdArrElabIsNet251 (control: a named-block local of a reg typedef in an initial block)
typedef reg r_t [2];
module top;
  initial begin : b
    r_t x;
    x[0] = 1'b0;
  end
endmodule
