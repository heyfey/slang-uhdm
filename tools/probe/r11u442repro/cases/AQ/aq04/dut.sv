// § paramBoundQTd442
module top;
  parameter P = 3;
  typedef int q_t [$:P-1];
  q_t a;
endmodule
