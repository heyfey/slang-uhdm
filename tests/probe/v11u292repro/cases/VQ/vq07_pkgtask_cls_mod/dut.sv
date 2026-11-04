// § pkgVarLvalueScopeSep292
package p; int q; int arr[2]; endpackage
package r;
  task automatic t(); p::q = 1; p::arr[0] = 2; endtask
  class c #(int N = 1);
    function void h(); p::q = N; endfunction
  endclass
  virtual class v; virtual function void vf(); p::q = 3; endfunction
    pure virtual function void pv();
  endclass
endpackage
module top;
  for (genvar g = 0; g < 1; g++) begin : gb
    class lc; function void h(); p::q = 4; endfunction endclass
  end
endmodule
