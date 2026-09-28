// § classSpecExprArgUnlocated202 (one typedef, one identifier argument of two type parameters)
class obj;
endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj) m1;
module top ();
  m1 b;
endmodule
