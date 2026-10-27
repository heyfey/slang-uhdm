// § modDynTdDefNetCopy442
module child;
  typedef int q_t[$];
  q_t q;
endmodule
module top;
  child u1();
  child u2();
endmodule
