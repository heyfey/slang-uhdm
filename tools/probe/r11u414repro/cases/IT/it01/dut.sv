// § ifaceClsScopedArgUnsup414
module class_tb ();
  interface class ihello;
    typedef int int_t;
    pure virtual function void hello(int_t val);
  endclass
  class Hello implements ihello;
    virtual function void hello(ihello::int_t val);
    endfunction
  endclass
  Hello obj;
endmodule
