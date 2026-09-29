// § initHierFillKept225 — fresh: a top-level '1 onto a signal whose width reads an assignment-pattern struct member
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 16};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
