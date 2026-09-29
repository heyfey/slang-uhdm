// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a size cast by a parameter width (W'(16))
typedef struct packed { int x; } info_t;
module top(output logic [7:0] o);
   localparam int W = 32;
   parameter info_t Info = W'(16);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
