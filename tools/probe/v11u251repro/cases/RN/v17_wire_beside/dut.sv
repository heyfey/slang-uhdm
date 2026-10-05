// § regTdArrElabIsNet251 (a reg typedef variable between two wires and a logic variable, the net list order)
typedef reg r_t [2];
module top;
  wire w1;
  r_t m;
  logic v;
  wire w2;
  assign w1 = m[0];
endmodule
