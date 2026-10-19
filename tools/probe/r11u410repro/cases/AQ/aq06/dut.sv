// § unitBoundedQTd410
typedef bit [1:0] p_t;
typedef p_t q_t [$:4];
module top;
  q_t a;
  initial a.push_back(2'b01);
endmodule
