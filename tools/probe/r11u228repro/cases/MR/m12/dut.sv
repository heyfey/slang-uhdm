// § memberInitReducedRootFolds228 — a package struct type, a localparam of the member width inside a generate block
package p;
   typedef struct packed { int x; } info_t;
endpackage
module top import p::*; (output int o);
   parameter info_t Info = '{default: 5};
   if (1) begin : g
      localparam int N = Info.x;
      logic [N-1:0] data;
      assign data = '1;
   end
   assign o = int'(g.data);
endmodule
