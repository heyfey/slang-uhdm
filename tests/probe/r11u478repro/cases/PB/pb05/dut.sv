// § providerBodyCopyBind478 (control: a direct importer only, no provider)
package u;
  function automatic int f(int x);
    int y;
    int z;
    y = x + 1;
    z = y * 2;
    return z;
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function int g(); return f(1); endfunction
  endclass
endpackage
module top; import a::*; A o; endmodule
