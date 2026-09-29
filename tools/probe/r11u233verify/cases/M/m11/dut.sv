// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — an override chain across three parent levels, two branches (untyped pattern then cast)
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module b #(parameter info_t PB = info_t'(1)) (output logic [7:0] o);
   sub #(.Info(PB)) u (.o(o));
endmodule
module a #(parameter info_t PA = info_t'(1)) (output logic [7:0] o);
   b #(.PB(PA)) ub (.o(o));
endmodule
module top(output logic [7:0] o1, o2);
   a #(.PA(info_t'(6))) a1 (.o(o1));
   a #(.PA('{x: 5})) a2 (.o(o2));
endmodule
