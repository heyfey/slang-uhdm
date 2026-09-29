// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  import "DPI-C" function void cf(input UVM_FILE x);
  export "DPI-C" function ef;
  function void ef(UVM_FILE y);
  endfunction
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
