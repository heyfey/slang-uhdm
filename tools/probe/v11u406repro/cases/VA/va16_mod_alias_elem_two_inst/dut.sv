// § aliasElemDynTd406
module child;
  typedef byte n_t;
  typedef n_t d_t [];
  d_t d;
endmodule
module top;
  child c1();
  child c2();
endmodule
