// § lineDirectiveIgnored416
package p;
`line 40 "dut.sv" 1
  class C;
    int x;
    function int get(); return x; endfunction
  endclass
endpackage
module top;
  p::C c;
endmodule
