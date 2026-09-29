// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a concatenation holding a replication
typedef struct packed { int x; int y; } info_t;
module top(output logic [7:0] o);
   parameter info_t Info = {{2{8'd0}}, 16'd0, 16'd16};
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
