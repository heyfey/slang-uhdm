// § memberInitReducedRootFolds228 — a chain with a cast root (the substitution stays)
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = info_t'(12);
   parameter info_t I2 = Info;
   localparam int N = I2.x;
   logic [N-1:0] data;
   assign data = '0;
   assign o = int'(data);
endmodule
