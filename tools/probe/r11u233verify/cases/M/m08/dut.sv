// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — an array of instances with an untyped override beside a single cast instance
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top(output logic [7:0] o1 [2], output logic [7:0] o2);
   sub #(.Info('{x: 5})) ua [1:0] (.o(o1));
   sub #(.Info(info_t'(6))) ub (.o(o2));
endmodule
