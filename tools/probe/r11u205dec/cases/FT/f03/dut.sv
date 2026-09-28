// r11u205 FT f03: a class method formal typed by a package `typedef int`
package p;
  typedef int act_t;
  class c;
    function void set(act_t a);
      v = a;
    endfunction
    act_t v;
  endclass
endpackage
module dut(output logic o);
  assign o = 1'b0;
endmodule
