// § classSpecExprArgUnlocated202 (two typedefs of one generic class, one argument first, then two)
class obj;
endclass
class obj2;
endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj) m1;
typedef cfg#(obj, obj2) m2;
module top ();
  m2 a;
  m1 b;
endmodule
