// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
endpackage
module top;
  import p::*;
  function automatic int set(UVM_FILE file);
    return file;
  endfunction
  UVM_FILE f;
  initial f = set(3);
endmodule
