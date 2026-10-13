// § lvIdxThisPathIsRead312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class grid; int i; int ia[4]; int r; task t(output int o); o = 1; endtask
  task probe(); t(ia[this.i]); endtask endclass
module top; endmodule
