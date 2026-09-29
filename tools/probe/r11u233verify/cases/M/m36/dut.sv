// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a real literal root converted
typedef struct packed { int x; } info_t;
module top(output logic [7:0] o);
   parameter info_t Info = 16.0;
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
