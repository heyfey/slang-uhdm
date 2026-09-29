// § memberInitReducedRootFolds228 — a struct localparam with an untyped pattern, and a sized literal root
module top(output int o);
   typedef struct packed { int x; } info_t;
   localparam info_t LI = '{x: 5};
   parameter info_t Info = 32'd9;
   localparam int N = LI.x;
   localparam int M = Info.x;
   logic [N-1:0] da;
   logic [M-1:0] db;
   assign da = '1;
   assign db = '1;
   assign o = int'(da) + int'(db);
endmodule
