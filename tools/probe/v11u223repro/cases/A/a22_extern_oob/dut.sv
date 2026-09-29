// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c;
    extern function void f(UVM_FILE x, int k);
    extern virtual task t(UVM_FILE y);
    extern static function UVM_FILE s(UVM_FILE z);
  endclass
  function void c::f(UVM_FILE x, int k);
  endfunction
  task c::t(UVM_FILE y);
  endtask
  function UVM_FILE c::s(UVM_FILE z);
    return z;
  endfunction
endpackage
module top;
  import p::*;
  UVM_FILE g;
endmodule
