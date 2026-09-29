// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — a concatenation of a struct parameter ({B})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t B = info_t'(16);
   parameter info_t Info = {B};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
