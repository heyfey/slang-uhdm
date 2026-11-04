// § parenCallCallee479
class B #(type T = int); virtual function int m(int a); return a; endfunction endclass
class d extends B#(int);
  function int m(int a); return (super.m(a)); endfunction
endclass
module top; endmodule
