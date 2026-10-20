// § foreachArrayNamesClass417
class b;
  int v;
endclass
class A;
  int b[3];
  int n;
  function int f();
    foreach (b[i]) n += i;
    return n;
  endfunction
endclass
module top;
endmodule
