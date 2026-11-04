// § opIdxRecvElemFollowsPath215 — receiver indices built from a parameter, a localparam, a call and a nested operation in a package class
package p;
  parameter int P = 3;
  class fld;
    function int get(); return 0; endfunction
  endclass
  class reg_c;
    localparam int L = 2;
    fld fields[8];
    function int idx(int i); return i; endfunction
    function int f(int i);
      int a;
      a = fields[P-1].get();
      a += fields[L+i].get();
      a += fields[idx(i)+1].get();
      a += fields[(i*2)-(P-2)].get();
      a += fields[i%4].get();
      return a;
    endfunction
  endclass
endpackage
module m;
endmodule
