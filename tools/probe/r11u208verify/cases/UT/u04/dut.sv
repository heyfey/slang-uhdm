// § classSpecExprArgUnlocated202 § unitClassTdSpecAtName202 § unitClassTdEndAtInit202
class obj;
endclass
class obj2;
endclass
class cfg#(type T=int, type T2=int);
  function new(int k = 0); endfunction
endclass
typedef cfg#(obj, obj2) m2;
typedef cfg#(obj) m1;
module top ();
  m2 a = new(3);
  m1 b = new;
  cfg#(obj, obj2) c;
endmodule
