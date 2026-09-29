// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class base;
    function new(UVM_FILE f = 0);
    endfunction
    static function int s(UVM_FILE g);
      return g;
    endfunction
    virtual function void v(UVM_FILE h);
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class der extends base;
    function new(UVM_FILE f = 1);
      super.new(f);
    endfunction
    virtual function void v(UVM_FILE h);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  UVM_FILE f;
endmodule
