// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — an untyped pattern reading an untyped struct parameter of another type ('{x: C.y})
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   typedef struct packed { int z; int y; } c_t;
   parameter c_t C = '{z: 1, y: 16};
   parameter info_t Info = '{x: C.y};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
