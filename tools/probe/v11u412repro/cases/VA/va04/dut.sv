// § assocClassIdxNet412
class C; endclass
class D;
  int parr [C];
endclass
module top;
  D d;
  function void f();
    int farr [C];
  endfunction
endmodule
