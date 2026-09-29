// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — two instances of a child, both untyped overrides with different widths and a cast-default third definition listing
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = info_t'(4)) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top(output logic [7:0] o1, o2);
   sub #(.Info('{x: 5})) u1 (.o(o1));
   sub #(.Info('{x: 7})) u2 (.o(o2));
endmodule
