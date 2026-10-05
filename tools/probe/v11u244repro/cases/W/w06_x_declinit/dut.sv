// § cloneNewArrayCallParented244
package p;
  class fac;
    int n = 2;
    int md[] = new[4];
    extern function int emit();
  endclass
  function int fac::emit();
    int d[] = new[n];
    automatic int e[] = new[n + 1](d);
    begin
      int f[] = new[d.size()];
      return f.size() + e.size();
    end
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
