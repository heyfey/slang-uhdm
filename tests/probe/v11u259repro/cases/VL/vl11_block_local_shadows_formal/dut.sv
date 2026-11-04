// § cloneLoopVarHomeDeclTs259 (a nested-block local array of the same typedef shadows the formal of the same name)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(int off, ref addr_t addr[]);
    begin
      addr_t addr[];
      foreach (addr[i])
        addr[i] = off;
    end
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
