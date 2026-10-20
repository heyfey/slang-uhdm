// § classWildcardIdxRefTs414
class C;
  function void f();
    int a[*];
    a[1] = 2;
  endfunction
endclass
module top;
  C c;
endmodule
