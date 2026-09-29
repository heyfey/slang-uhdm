// § memberInitReducedRootFolds228 — a header included by two modules, one untyped root and one cast root
typedef struct packed { int x; } info_t;
module a(output int o);
   parameter info_t Info = '{x: 5};
`include "w.svh"
   assign o = int'(data);
endmodule
module top(output int o, output int o2);
   parameter info_t Info = info_t'(6);
`include "w.svh"
   assign o = int'(data);
   a u(.o(o2));
endmodule
