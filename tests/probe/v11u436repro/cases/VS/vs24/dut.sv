// § clsSpecSurelogOrder436
class B; endclass
class C #(parameter p = 2, type T = int) extends B;
endclass
module top;
C#(1, real) v;
initial v = new;
endmodule
