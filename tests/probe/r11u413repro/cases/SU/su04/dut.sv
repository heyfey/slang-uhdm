// § superMemberHierPath413
class P;
  int value;
  int w;
endclass
class L extends P;
  int value;
  function int g();
    return this.value + super.w;
  endfunction
endclass
module top;
endmodule
