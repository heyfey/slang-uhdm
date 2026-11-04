// § foreachArrayNamesClass417
class b;
  int v;
endclass
class C;
  int b[4];
  int n;
  function void run();
    foreach (b[k]) n += k;
  endfunction
endclass
module top;
endmodule
