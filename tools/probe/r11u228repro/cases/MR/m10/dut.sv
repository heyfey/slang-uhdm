// § memberInitReducedRootFolds228 — an interface signal of an untyped-pattern member width
typedef struct packed { int x; } info_t;
interface ifc;
   parameter info_t Info = '{x: 6};
   localparam int N = Info.x;
   logic [N-1:0] v;
endinterface
module top(output int o);
   ifc i();
   assign i.v = '1;
   assign o = int'(i.v);
endmodule
