// § paramBoundQTd442
module child #(parameter P = 2);
  typedef bit q_t [$:P];
  q_t a;
endmodule
module top;
  child #(4) u1();
  child #(6) u2();
endmodule
