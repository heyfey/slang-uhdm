// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a shift of literals and a name (W << 2)
typedef struct packed { int x; } info_t;
module top(output logic [7:0] o);
   localparam int W = 4;
   parameter info_t Info = W << 2;
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
