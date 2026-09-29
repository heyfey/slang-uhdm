// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  function void ef(UVM_FILE y);
  endfunction
  export "DPI-C" function ef;
endpackage
module top;
  import p::*;
  UVM_FILE f;
endmodule
