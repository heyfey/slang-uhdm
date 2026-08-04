package p;
  class Inner;
    int x;
  endclass

  virtual class A;
    pure virtual function Inner pvc(int a);
    pure virtual function int pvi();
    pure virtual function string pvs(int b, string c);
    pure virtual task pvt(int d);
  endclass

  class B extends A;
    virtual function Inner pvc(int a);
      return null;
    endfunction
    virtual function int pvi();
      return 0;
    endfunction
    virtual function string pvs(int b, string c);
      return "";
    endfunction
    virtual task pvt(int d);
    endtask
  endclass
endpackage

module top;
  initial begin
  end
endmodule
