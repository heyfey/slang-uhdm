// § cloneVarSelBind450
package p;
  function automatic void f(int i0);
    logic [3:0][7:0] m;
    begin
      logic [3:0][7:0] m;
      m[i0][1] = 1;
    end
    m[i0][2] = 0;
  endfunction
  function int g(int i0);
    static logic [3:0][7:0] sm;
    sm[i0][0] = 1;
    return sm[i0][1];
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
