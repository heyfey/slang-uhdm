// § memberInitReducedRootFolds228 — the override a parent parameter whose own value is a cast
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top #(parameter info_t PI = info_t'(6)) (output logic [7:0] o);
   sub #(.Info(PI)) u (.o(o));
endmodule
