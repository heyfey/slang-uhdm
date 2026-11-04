// § cloneViaProviderTopClone476
package u;
  function automatic int f(int x);
    int y, q[$];
    q.push_back(x);
    y = q.size();
    foreach (q[j]) y += q[j];
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
