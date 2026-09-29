// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  parameter UVM_FILE STDOUT = 1;
  class b;
    function void set_b(UVM_FILE file);
    endfunction
  endclass
  class a;
    function void set_a(int x, UVM_FILE file);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  UVM_FILE f = STDOUT;
endmodule
