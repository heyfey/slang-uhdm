// § thisCallResultMemberDropped415
class B;
  int s = 2;
  function B mk();
    B o = new;
    return o;
  endfunction
endclass
class C extends B;
  function int g();
    return super.mk().s;
  endfunction
endclass
module top(output int r);
  C h;
  initial begin h = new; r = h.g(); end
endmodule
