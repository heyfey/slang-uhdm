// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — an override chain across two instances of the parent: mid m1 passes an untyped pattern, m2 a cast
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module mid #(parameter info_t PI = info_t'(1)) (output logic [7:0] o);
   sub #(.Info(PI)) u (.o(o));
endmodule
module top(output logic [7:0] o1, o2);
   mid #(.PI('{x: 5})) m1 (.o(o1));
   mid #(.PI(info_t'(6))) m2 (.o(o2));
endmodule
