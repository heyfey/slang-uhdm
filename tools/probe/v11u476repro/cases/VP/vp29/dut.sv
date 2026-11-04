// § cloneViaProviderTopClone476
package u;
  typedef struct { int d; int e; } r_t;
  function automatic int f(int x);
    r_t arr[2];
    int y;
    y = 0;
    foreach (arr[i]) begin
      arr[i].d = x;
      y += arr[i].d + arr[i].e;
    end
    return y;
  endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return f(1);
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
