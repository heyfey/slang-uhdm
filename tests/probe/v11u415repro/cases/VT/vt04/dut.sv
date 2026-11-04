// § thisCallResultMemberDropped415
class B;
  int s = 3;
  function B mk();
    B o = new;
    return o;
  endfunction
endclass
class D extends B;
  function int g();
    return super.mk().s;
  endfunction
endclass
module top(output int r);
  D h;
  initial begin h = new; r = h.g(); end
endmodule
