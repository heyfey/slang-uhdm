// § memberInitReducedRootFolds228 — a chain: the member read through a second struct parameter whose value is the first (untyped root)
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 12};
   parameter info_t I2 = Info;
   localparam int N = I2.x;
   logic [N-1:0] data;
   assign data = '0;
   assign o = int'(data);
endmodule
