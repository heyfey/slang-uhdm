// § castRhsClonePerInst176
module leaf(input logic [3:0] w);
   assign a = int'(w);
endmodule
module mid(input logic [3:0] w);
   leaf l(w);
endmodule
module top();
   logic [3:0] w;
   mid m1(w);
   mid m2(w);
endmodule
