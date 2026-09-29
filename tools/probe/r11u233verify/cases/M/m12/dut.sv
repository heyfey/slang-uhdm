// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — defparam overrides: u1 an untyped pattern by defparam, u2 a cast by defparam
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top(output logic [7:0] o1, o2);
   sub u1 (.o(o1));
   sub u2 (.o(o2));
   defparam u1.Info = '{x: 5};
   defparam u2.Info = info_t'(6);
endmodule
