// § pureVirtRetSpecWholeSpan234: the classes declared in a module
module top;
  class comp; endclass
  virtual class vis #(type N = int); endclass
  virtual class cs;
    pure virtual function vis#(comp) get_v();
  endclass
endmodule
