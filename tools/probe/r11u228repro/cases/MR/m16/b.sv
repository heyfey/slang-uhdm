// § memberInitReducedRootFolds228 — two files, the same declarator position in both (the cast twin)
module other(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
