// § tfArgScalarTdCallArgFollows231 — a task call and a second formal of a builtin type
package p;
  typedef int UVM_FILE;
  typedef bit [3:0] nib_t;
endpackage
module top(input int a, input bit [3:0] n);
  import p::*;
  int acc;
  task automatic t(UVM_FILE f, int k, nib_t q);
    acc = f + k + q;
  endtask
  initial t(a, a, n);
endmodule
