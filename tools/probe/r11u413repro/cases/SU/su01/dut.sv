// § superMemberHierPath413
class P;
  int value;
  int w;
endclass
class L extends P;
  int value;
  function int d();
    d = value * super.value;
  endfunction
endclass
module top;
endmodule
