// § foreachArrayNamesTypedef417
typedef int b;
module top;
  int n;
  function int f();
    int b[3];
    foreach (b[i]) n += i;
    return n;
  endfunction
  initial n = f();
endmodule
