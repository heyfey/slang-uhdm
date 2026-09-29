// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a function-call root (a constant function building the struct)
typedef struct packed { int x; } info_t;
function automatic info_t mk(int v);
   mk.x = v;
endfunction
module top(output logic [7:0] o);
   parameter info_t Info = mk(16);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
