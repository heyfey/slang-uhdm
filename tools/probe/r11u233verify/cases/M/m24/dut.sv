// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — an arithmetic of a cast struct parameter (B + 0)
typedef struct packed { int x; } info_t;
module top(output logic [7:0] o);
   parameter info_t B = info_t'(16);
   parameter info_t Info = B + 0;
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
