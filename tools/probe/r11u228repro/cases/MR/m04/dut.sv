// § memberInitReducedRootFolds228 — a child's untyped default overridden by a cast in the parent
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top(output logic [7:0] o);
   sub #(.Info(info_t'(8))) u (.o(o));
endmodule
