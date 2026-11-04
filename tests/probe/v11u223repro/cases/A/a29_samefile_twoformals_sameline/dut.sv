// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class a; function void f(UVM_FILE x); endfunction function void g(UVM_FILE y); endfunction endclass
  class b; function void f(UVM_FILE x); endfunction endclass
endpackage
module top;
  import p::*;
  UVM_FILE g;
endmodule
