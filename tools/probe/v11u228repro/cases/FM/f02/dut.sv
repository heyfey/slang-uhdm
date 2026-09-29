// § memberInitReducedRootFolds228 — a conditional of untyped patterns as the struct parameter's value
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = SEL ? '{x: 5} : '{x: 9};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
