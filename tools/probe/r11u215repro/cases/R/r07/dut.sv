// § opIdxRecvPlainElab215 — a package FREE function reading a handle array's method through a plain and an operation index, cloned into an importing module (r10uvm39repro/t55b's shape: golden keeps the scope's name on the plain index in the elaborated view)
package home;
  class inner;
    function int one(int a); return a; endfunction
  endclass
  function automatic int fIndex(int i4, int f4);
    inner parr[4];
    return parr[i4].one(f4) + parr[i4-1].one(f4);
  endfunction
endpackage
module mm(input int k, output int o);
  import home::*;
  assign o = fIndex(k, 1);
endmodule
