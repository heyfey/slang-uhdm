// § unpStructArrElemVar412
module top();
  typedef struct {
    int a;
    int b;
  } ms_t;
  ms_t ms[1:0] = '{'{0, 0}, '{1, 1}};
  ms_t mt[2];
endmodule
