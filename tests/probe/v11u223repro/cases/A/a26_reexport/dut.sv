// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
endpackage
package q;
  import p::*;
  export p::*;
  class c;
    function void f(UVM_FILE x);
    endfunction
  endclass
endpackage
module top;
  import q::*;
  UVM_FILE g;
endmodule
