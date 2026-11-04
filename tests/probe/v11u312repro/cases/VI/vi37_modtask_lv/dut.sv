// § methRecvIdxAtPath312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; endclass
module top; item iarr[4]; holder h; int r;
  task t(input int i); h.idx[iarr[i].get()] = r; endtask
endmodule
