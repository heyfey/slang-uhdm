// § paramBoundQTd442
module top #(parameter int W = 4);
  localparam L = W * 2;
  typedef logic [7:0] q_t [$:L];
  q_t a;
endmodule
