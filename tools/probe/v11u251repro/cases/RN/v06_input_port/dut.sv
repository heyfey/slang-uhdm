// § regTdArrElabIsNet251 (ANSI input port of a reg typedef array)
typedef reg r_t [4];
module child(input r_t i, output logic o);
  assign o = i[0];
endmodule
module top;
  r_t s; logic o;
  child c(.i(s), .o(o));
endmodule
