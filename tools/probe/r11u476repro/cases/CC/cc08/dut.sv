// § cloneViaProviderTopClone476
package u;
  function automatic int f(int x);
    int y;
    y = x + 1;
    return y;
  endfunction
  task automatic tk(input int x);
    int z;
    z = x;
    begin
      int w;
      w = z;
    end
  endtask
endpackage
package a;
  import u::*;
endpackage
package t;
  import a::*;
  int q;
endpackage
module top; import t::*; endmodule
