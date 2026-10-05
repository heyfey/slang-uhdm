// § regTdArrElabIsNet251 (control: a class property of a reg typedef is not an elaborated signal)
typedef reg r_t [2];
class c; r_t m; endclass
module top;
  c h;
  r_t v;
endmodule
