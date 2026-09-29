// § memberRootFoldShapes228v — the struct parameter's value: (SEL ? info_t'(5) : info_t'(9))
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = (SEL ? info_t'(5) : info_t'(9));
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
