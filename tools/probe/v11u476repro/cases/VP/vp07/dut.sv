// § cloneViaProviderTopClone476
package u;
  typedef struct { int a; int b; } s_t;
  function automatic int f(int arr[], s_t s);
    int y;
    s_t q;
    q = s;
    y = q.a + s.b;
    foreach (arr[i]) y += arr[i];
    begin : blk
      int z;
      z = y;
      y = z + 1;
    end
    return y;
  endfunction
endpackage
package a;
  import u::*;
  class AC;
    function int g();
      return f('{1,2}, '{1,2});
    endfunction
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
