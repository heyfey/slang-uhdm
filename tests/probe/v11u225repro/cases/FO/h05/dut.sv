// § initHierFillKept225 — fresh: a top-level '1 onto a signal whose width reads a member of a struct parameter initialized by info_t'(32'd16)
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = info_t'(32'd16);
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
