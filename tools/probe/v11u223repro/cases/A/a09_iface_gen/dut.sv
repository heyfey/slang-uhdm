// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
endpackage
interface bus;
  import p::*;
  int v;
  task automatic put(UVM_FILE f);
    v = f;
  endtask
  function automatic int get(UVM_FILE g);
    return g;
  endfunction
  modport mp(import put, import get);
endinterface
module top(input int a, output int o);
  import p::*;
  bus b();
  if (1) begin : gb
    function automatic int h(UVM_FILE z);
      return z + 2;
    endfunction
    assign o = h(a);
  end
endmodule
