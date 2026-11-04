// § paramBoundQTd442
module child #(parameter P = 3);
  typedef int q_t [$:P];
  q_t a;
endmodule
module top;
  child #(.P(5)) u();
endmodule
