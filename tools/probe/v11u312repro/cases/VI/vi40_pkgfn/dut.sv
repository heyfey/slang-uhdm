// § methRecvIdxAtPath312
package q; class item; int f; function int get(); return f; endfunction endclass function automatic int g(item iarr[4], int ia[4], int i); return ia[iarr[i].get()]; endfunction endpackage
module top; endmodule
