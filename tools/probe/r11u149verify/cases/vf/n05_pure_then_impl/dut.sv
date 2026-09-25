// § classMethodQualSpan144
package p;
  virtual class b;
    pure virtual function int f();
    pure virtual task t();
  endclass
  class d extends b;
    virtual function int f();
      return 1;
    endfunction
    virtual task t();
    endtask
    static function int g();
      return 2;
    endfunction
  endclass
endpackage
module dut;
endmodule
