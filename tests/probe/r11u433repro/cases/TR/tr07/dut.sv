// § classRetFillUnsized433
package p;
  class C;
    function logic [3:0] g();
      return '1;
    endfunction
    extern function logic [5:0] h();
  endclass
  function logic [5:0] C::h();
    return '0;
  endfunction
endpackage
module top; import p::*; endmodule
