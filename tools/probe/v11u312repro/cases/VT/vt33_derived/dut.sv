// § lvIdxThisPathIsRead312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class base; int i; int ia[4]; int r; endclass
class grid extends base; function void probe(); ia[this.i] = r; ia[super.i] = r; endfunction endclass
module top; endmodule
