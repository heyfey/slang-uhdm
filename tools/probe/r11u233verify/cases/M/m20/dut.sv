// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a root in a package: Info = pk::BASE, BASE a cast
package pk;
   typedef struct packed { int x; } info_t;
   localparam info_t BASE = info_t'(16);
endpackage
module top(output logic [7:0] o);
   parameter pk::info_t Info = pk::BASE;
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
