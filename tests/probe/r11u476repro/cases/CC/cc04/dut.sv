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
  class A;
    function int g();
      return f(1);
    endfunction
  endclass
endpackage
package b;
  import u::*;
  class B;
  endclass
endpackage
package t;
  import b::*;
  import a::*;
  class T; A h; B k; endclass
endpackage
module top; import t::*; T o; endmodule
