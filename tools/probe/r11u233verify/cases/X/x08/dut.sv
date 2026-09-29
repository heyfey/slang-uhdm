// § memberRootOwnInstance228v § memberInitReducedRootFolds228 — a three-level chain: top > mid > sub > leaf, the leaf range read through two int overrides, mid instances untyped then cast
typedef struct packed { int x; } info_t;
module leaf #(parameter int D2 = 8) (output logic [D2-1:0] a);
   assign a = '0;
endmodule
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   leaf #(.D2(Depth)) l (.a(a));
endmodule
module mid #(parameter info_t Info = '{x: 4}) (output int o);
   localparam int N = Info.x;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule
module top(output int o1, o2);
   mid #(.Info('{x: 5})) m1 (.o(o1));
   mid #(.Info(info_t'(6))) m2 (.o(o2));
endmodule
