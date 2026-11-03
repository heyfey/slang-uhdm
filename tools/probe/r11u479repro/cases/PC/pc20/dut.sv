// § parenCallCallee479
class base;
  virtual task tk(int a); endtask
endclass
class d extends base;
  function int m(int a);
    return (1);
  endfunction
endclass
module top; endmodule
