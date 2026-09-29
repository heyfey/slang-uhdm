// § memberRootFoldShapes228v § memberInitReducedRootFolds228 — a typed default pattern and an untyped replication pattern side by side
module top(output int o);
   typedef struct packed { int x; int y; } info_t;
   parameter info_t IA = info_t'{default: 6};
   parameter info_t IB = '{2{7}};
   localparam int NA = IA.x;
   localparam int NB = IB.y;
   logic [NA-1:0] da;
   logic [NB-1:0] db;
   assign da = '1;
   assign db = '1;
   assign o = int'(da) + int'(db);
endmodule
