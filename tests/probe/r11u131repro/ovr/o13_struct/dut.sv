// § ovrMultiDimConstUnparented131
module sub;
  typedef struct packed { logic [3:0] a; logic [1:0] b; } s_t;
  parameter s_t P = '0;
endmodule
module top ();
  sub #(.P(6'b1)) u();
endmodule
