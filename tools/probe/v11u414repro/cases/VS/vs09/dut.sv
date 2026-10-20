// § structMemberDefault414
module top;
  typedef struct { int a = 3; } in_t;
  typedef struct { in_t i; int b = 4; } out_t;
  out_t o;
endmodule
