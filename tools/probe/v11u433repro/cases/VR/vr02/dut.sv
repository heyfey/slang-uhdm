// § classRetFillUnsized433
package p;
  class C;
    function logic [3:0] f(); return '1; endfunction
  endclass
endpackage
module top; p::C c; initial c = new; endmodule
