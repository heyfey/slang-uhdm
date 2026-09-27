package p;
typedef bit [8-1:0] be_t;
typedef struct { int n; be_t byte_en; } op_t;
endpackage
module top;
  import p::*;
  int y;
endmodule
