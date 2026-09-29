// § memberInitReducedRootFolds228 — a plain integer struct parameter, an ANSI port of the member width
module top #(parameter int unsigned P = 0) (output logic [15:0] o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = 16;
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = 16'hABCD;
   assign o = q;
endmodule
