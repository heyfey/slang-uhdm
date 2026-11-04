// § classCallResultMemberRef413
class C;
  int s = 2;
  function C mk();
    C o = new;
    return o;
  endfunction
endclass
class D;
  C other;
  function int g();
    return other.mk().s;
  endfunction
endclass
module top(output int r);
  D d;
  initial begin d = new; r = d.g(); end
endmodule
