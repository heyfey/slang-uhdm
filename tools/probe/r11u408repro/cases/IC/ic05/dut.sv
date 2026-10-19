// § ifaceClassNotListed408
module test;
  interface class ihello;
    pure virtual function void hello();
  endclass
  class Hello implements ihello;
    virtual function void hello();
      $display("hello");
    endfunction
  endclass
  Hello obj;
  initial begin
    obj = new;
    obj.hello();
  end
endmodule
