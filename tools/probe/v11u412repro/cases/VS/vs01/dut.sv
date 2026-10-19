// § unpStructArrElemVar412
typedef struct { logic [3:0] a; int b; } ms_t;
class C;
  ms_t arr[2];
endclass
module top;
  C c;
endmodule
