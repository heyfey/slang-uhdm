// § classSpecExprArgUnlocated202 (one typedef, two identifier arguments)
class obj;
endclass
class obj2;
endclass
class cfg#(type T=int, type T2=int);
endclass
typedef cfg#(obj, obj2) m2;
module top ();
  m2 a;
endmodule
