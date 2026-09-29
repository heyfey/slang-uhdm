// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  typedef int unsigned uint_t;
  typedef longint lint_t;
  typedef shortint sint_t;
  class c;
    task t(output UVM_FILE file, ref uint_t u, input lint_t l, sint_t s);
    endtask
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
