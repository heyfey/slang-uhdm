// § paramBoundQTd442
module top;
  parameter logic [3:0] P = 4'd9;
  typedef int q_t [$:P];
  q_t a;
endmodule
