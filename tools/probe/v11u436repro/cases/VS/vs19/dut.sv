// § clsSpecSurelogOrder436
class C #(type T = int, int N = 3);
endclass
module top;
parameter W = 5;
C#(int, W) v;
endmodule
