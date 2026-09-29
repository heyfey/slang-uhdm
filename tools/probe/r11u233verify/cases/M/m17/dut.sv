// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — an unpacked struct parameter with an untyped pattern root
typedef struct { int x; int y; } uinfo_t;
module top(output logic [7:0] o);
   parameter uinfo_t Info = '{x: 16, y: 2};
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
