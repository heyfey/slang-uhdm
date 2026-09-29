// § memberInitReducedRootFolds228 — a package-qualified typed pattern (the substitution stays)
package p;
   typedef struct packed { int x; } info_t;
endpackage
module top(output int o);
   parameter p::info_t Info = p::info_t'{x: 11};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
