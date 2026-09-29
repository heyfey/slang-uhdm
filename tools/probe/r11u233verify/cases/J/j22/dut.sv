// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — a subtraction of two literals inside a concatenation beside a struct-free replication
module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed { int x; } info_t;
   parameter info_t Info = {{1{16'd0}}, 16'd0, 16'd20 - 16'd4};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
