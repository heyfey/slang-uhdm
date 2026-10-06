// § cloneLoopVarHomeDeclTs259 (an in-body class method over a class-property array of the typedef)
package p;
  typedef bit unsigned [63:0] addr_t;
  class c;
    addr_t arr[];
    function int f(int off, ref addr_t addr[]);
      foreach (addr[i])
        addr[i] = addr[i] + off;
      foreach (arr[j])
        arr[j] = 0;
      return 0;
    endfunction
  endclass
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
