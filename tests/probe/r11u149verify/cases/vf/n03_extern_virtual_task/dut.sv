// § classMethodQualSpan144
package p;
  class c;
    extern protected virtual task t(input int a);
    extern virtual function int f();
  endclass
  task c::t(input int a);
  endtask
  function int c::f();
    return 2;
  endfunction
endpackage
module dut;
endmodule
