// § cloneViaProviderTopClone476
package u;
  typedef struct { int a; int b; } s_t;
  task automatic f(int x);
    s_t q;
    begin : nb
      int z;
      q.a = x;
      z = q.a;
      q.b = z;
      if (z > 3) disable nb;
    end
  endtask
endpackage
package a;
  import u::*;
  class AC;
    task g(); f(1); endtask
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
