// § modTfLvTrailIdxNamesByChain312
package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass
module top; holder h; int r;
  for (genvar g = 0; g < 2; g++) begin : gl
    task t(input int i); h.idx[i + g] = r; endtask
  end
endmodule
