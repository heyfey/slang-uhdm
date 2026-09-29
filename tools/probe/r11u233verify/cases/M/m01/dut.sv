// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — three instances in the order PIC (P untyped pattern, I integer, C cast) of a child with an untyped default
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top(output logic [7:0] o1, o2, o3);
   sub #(.Info('{x: 5})) u1 (.o(o1));
   sub #(.Info(6)) u2 (.o(o2));
   sub #(.Info(info_t'(7))) u3 (.o(o3));
endmodule
