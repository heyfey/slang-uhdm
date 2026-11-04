// § superMemberHierPath413
class P;
  int value;
  int w;
endclass
class L extends P;
  int value;
  function void f();
    super.value = 3;
  endfunction
endclass
module top;
endmodule
