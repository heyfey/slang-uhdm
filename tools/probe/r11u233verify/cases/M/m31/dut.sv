// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — an untyped pattern whose inner member is a cast (Info.a.x)
typedef struct packed { int x; } in_t;
typedef struct packed { in_t a; int y; } info_t;
module top(output logic [7:0] o);
   parameter info_t Info = '{a: in_t'(16), y: 0};
   localparam int N = Info.a.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
