// § clsSpecSurelogOrder436
class C #(parameter p = 2, type T = int);
endclass
module top;
typedef logic [3:0] t4;
C#(1, t4) v;
endmodule
