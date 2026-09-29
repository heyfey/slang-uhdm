// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a member two deep (Info.a.x), untyped nested pattern root
typedef struct packed { int x; } in_t;
typedef struct packed { in_t a; int y; } info_t;
module top(output logic [7:0] o);
   parameter info_t Info = '{a: '{x: 16}, y: 3};
   localparam int N = Info.a.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
