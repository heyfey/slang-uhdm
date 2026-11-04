// § clsSpecSurelogOrder436
class C #(type T = int, type U = int);
  T a; U b;
endclass
module top;
C#(real) v;
initial v = new;
endmodule
