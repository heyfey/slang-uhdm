// § cloneLhsIdxPartSelBind450
package p;
  function automatic void f(int n);
    for (int j = 0; j < n; j++) begin
      bit [63:0] data;
      for (int i0 = 0; i0 < 8; i0++)
        data[i0*8+:8] = 8'hff;
    end
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
