// § unpackedStructVarPosInit420
module child;
  typedef struct { int a; int b; } t;
  t s = '{5, 6};
endmodule
module top;
  child u1();
  child u2();
endmodule
