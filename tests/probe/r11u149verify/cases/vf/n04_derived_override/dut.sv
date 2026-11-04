// § classMethodQualSpan144
package p;
  class b;
    virtual function void f();
    endfunction
    virtual task t();
    endtask
  endclass
  class d extends b;
    virtual function void f();
      super.f();
    endfunction
    task t();
    endtask
  endclass
endpackage
module dut;
endmodule
