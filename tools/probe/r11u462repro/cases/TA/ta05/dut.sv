// § clsMethodOwnAutomatic462
module top;
  virtual class C;
    local task automatic a();
    endtask
    protected function automatic int b();
      return 1;
    endfunction
    virtual task automatic c();
    endtask

  endclass
  class D extends C;
    virtual task automatic d();
    endtask
  endclass
  D x;
endmodule
