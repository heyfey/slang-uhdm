// § initHierAtRefToken225 — a nested member path Info.a.b
module top(output int o);
   typedef struct packed { int b; } in_t;
   typedef struct packed { in_t a; int c; } part_info_t;
   parameter part_info_t Info = '{a: '{b: 8}, c: 3};
   localparam int N = Info.a.b;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule : top
