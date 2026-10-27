// § paramBoundQTd442
module top;
  localparam L = 7;
  typedef logic [7:0] q_t [$:L];
  q_t a;
  initial a.push_back(8'h1);
endmodule
