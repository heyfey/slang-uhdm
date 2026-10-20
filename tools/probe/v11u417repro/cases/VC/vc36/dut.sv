// § foreachArrayNamesClass417
class b;
  int v;
endclass
class A;
  int n;
  extern function int f();
endclass
function int A::f();
  int b[3];
  foreach (b[i]) n += i;
  return n;
endfunction
module top;
endmodule
