// § memberRootFoldShapes228v § memberInitReducedRootFolds228 — a non-struct cast as the value (unsigned'(16)) and a parenthesized untyped pattern
module top(output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t IA = unsigned'(16);
   parameter info_t IB = ('{x: 7});
   localparam int NA = IA.x;
   localparam int NB = IB.x;
   logic [NA-1:0] da;
   logic [NB-1:0] db;
   assign da = '1;
   assign db = '1;
   assign o = int'(da) + int'(db);
endmodule
