// § memberRootFoldShapes228v — the struct parameter's value: I0
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   localparam int W = 13;
   parameter info_t I0 = info_t'(7);
   parameter info_t Info = I0;
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
