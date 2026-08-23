// b10: the UVM_RADIX shape -- a package parameter used by classes in the same
// package and imported by a module, with a second package that re-reads it.
package b10_pkg;
  parameter UVM_RADIXish = 'hf000000;
  parameter UVM_MASKish  = 'hffffffff;
  typedef enum { A, B } e_t;
  class b10_obj;
    parameter CP = 'h7;
    function int f(); return UVM_RADIXish | UVM_MASKish | CP; endfunction
  endclass
endpackage
module b10_use;
  import b10_pkg::*;
  b10_obj o;
  initial begin o = new(); $display(UVM_RADIXish, o.f()); end
endmodule
module b10_top;
  b10_use u0();
endmodule
