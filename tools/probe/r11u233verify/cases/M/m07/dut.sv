// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a cast default, the first instance an untyped override, the second the default (the definition listing reads the default)
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = info_t'(4)) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top(output logic [7:0] o1, o2);
   sub #(.Info('{x: 5})) u1 (.o(o1));
   sub u2 (.o(o2));
endmodule
