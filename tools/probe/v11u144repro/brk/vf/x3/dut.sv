// § classMethodQualSpan144
module top;
  class C;
    extern virtual function void f();
    extern static task t();
    virtual task v(); endtask
  endclass
  function void C::f(); endfunction
  task C::t(); endtask
endmodule
