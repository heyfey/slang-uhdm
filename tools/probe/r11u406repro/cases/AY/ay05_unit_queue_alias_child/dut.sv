// § aliasElemDynTd406
typedef bit [1:0] p_t;
typedef p_t q_t [$];
module child;
  q_t q;
endmodule
module top;
  child c();
  q_t r;
endmodule
