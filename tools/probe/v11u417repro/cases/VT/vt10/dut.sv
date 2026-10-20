// § foreachArrayNamesTypedef417
typedef int b;
class A;
  int n;
  function int f();
    int b[3];
    foreach (b[i]) n += i;
    return n;
  endfunction
endclass
module top;
endmodule
