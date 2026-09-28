// § genScopeClassVarSpecAtName206 (a parameter as the value argument; a nested specialization as the type argument)
class c #(type T = int); T t; endclass
class w #(int W = 4); logic [W-1:0] v; endclass
module s02 #(parameter int P = 6) ();
  for (genvar i = 0; i < 2; i++) begin : g
    w #(P) a;
    c #(w #(2)) b;
    w #(i + 1) d;
  end
endmodule
