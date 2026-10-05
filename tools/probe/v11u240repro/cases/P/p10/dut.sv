// § hoistPoolSourceOrder240: an implicit net and an outside net beside the hoist, a generate block, a call as an index
package hp;
  class zb;
    int cnt;
    int arr[4];
    extern function int f(int i);
    extern function int get();
  endclass
  function int zb::get();
    return arr[f(cnt)];
  endfunction
  function int zb::f(int i);
    return i + cnt;
  endfunction
endpackage
module top;
  import hp::*;
  wire o;
  assign imp_n = 1'b0;
  for (genvar g = 0; g < 2; g++) begin : gb
    assign o = imp_n;
  end
endmodule
