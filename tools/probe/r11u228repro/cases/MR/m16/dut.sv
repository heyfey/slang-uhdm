// § memberInitReducedRootFolds228 — two files, the same declarator position in both (untyped here, cast in b.sv)
module top(output int o, output int o2);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = '{x: 16};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
   other u(.o(o2));
endmodule
