// § initHierFillKept225 — fresh: a block-local variable of the substituted width shares its name with a plain module-scope signal written by '1
module top(output int o, output int p);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = info_t'(16);
   localparam int N = Info.x;
   logic [7:0] t;
   logic [N-1:0] u;
   assign t = '1;
   always_comb begin : blk
      logic [N-1:0] t;
      t = '0;
      u = t;
   end
   assign o = int'(t);
   assign p = int'(u);
endmodule
