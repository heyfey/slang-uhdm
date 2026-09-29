// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c #(type T = UVM_FILE);
    function void set(string id, T file);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  parameter type PT = UVM_FILE;
  function automatic int g(PT x);
    return x;
  endfunction
  c #(UVM_FILE) h;
  int y;
  assign y = g(3);
endmodule
