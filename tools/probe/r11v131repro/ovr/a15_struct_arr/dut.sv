// § ovrMultiDimConstUnparented131
typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
module sub #(parameter s_t [1:0] P = '0) ();
endmodule
module top ();
  sub #(.P(8'h5a)) u();
endmodule
