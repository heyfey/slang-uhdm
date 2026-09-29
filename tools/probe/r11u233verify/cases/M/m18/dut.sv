// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a selected side that is a struct parameter (SEL ? B : cast, B untyped)
typedef struct packed { int x; } info_t;
module top(output logic [7:0] o);
   parameter bit SEL = 1;
   parameter info_t B = '{x: 16};
   parameter info_t Info = SEL ? B : info_t'(9);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
