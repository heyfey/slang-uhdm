// § modUnpackedUnionTd402
module child;
  typedef union { int i; byte b; } u_t;
  u_t u;
endmodule
module top;
  child c1();
  child c2();
endmodule
