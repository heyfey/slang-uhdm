// § memberRootOwnInstance228v § initHierFillKept225 § fillSymbolicRootOnly225v — the parenthesized cast root beside an untyped one (fillSymbolicRootOnly225v does not read through parentheses)
typedef struct packed { int x; } info_t;
module sub #(parameter int Depth = 128) (output logic [Depth-1:0] a);
   assign a = '1;
endmodule
module mid #(parameter info_t Info = '{x: 4}) (output int o);
   localparam int N = Info.x;
   logic [N-1:0] data;
   sub #(.Depth(N)) u (.a(data));
   assign o = int'(data);
endmodule
module top(output int o1, o2);
   mid #(.Info((info_t'(6)))) m1 (.o(o1));
   mid #(.Info('{x: 5})) m2 (.o(o2));
endmodule
