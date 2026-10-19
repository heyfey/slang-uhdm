// § aliasElemDynTd406
typedef bit [1:0] a_t;
typedef a_t b_t;
typedef b_t q_t [$];
module top;
  q_t q;
endmodule
