// § pkgTfLvTrailIdxNamesByChain312
package p; class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
 task automatic t(holder h, int i); h.idx[i + 1] = 0; endtask endpackage
module top; endmodule
