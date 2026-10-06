// § cloneLoopVarHomeDeclTs259 (two foreach loops, one over a formal and one over a nested-block local of another typedef with the same name)
package p;
  typedef bit unsigned [63:0] addr_t;
  typedef bit unsigned [31:0] word_t;
  function automatic int f(int off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    begin
      word_t addr2[];
      foreach (addr2[j])
        addr2[j] = 0;
    end
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
