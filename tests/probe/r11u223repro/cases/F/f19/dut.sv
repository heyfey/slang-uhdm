// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
endpackage
interface ifc;
  import p::*;
  function automatic int set(UVM_FILE file);
    return file;
  endfunction
endinterface
module top;
  ifc i();
endmodule
