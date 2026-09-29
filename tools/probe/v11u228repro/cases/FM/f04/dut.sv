// § memberInitReducedRootFolds228 — a package struct parameter with an untyped pattern read through the package
package p;
   typedef struct packed { int x; } info_t;
   parameter info_t PI = '{x: 5};
endpackage
module top(output int o);
   localparam int N = p::PI.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
