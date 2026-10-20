// § thisCallResultMemberDropped415
class C;
  int s = 2;
  function C mk();
    C o = new;
    return o;
  endfunction
  function void show();
    $display("%0d", this.mk().s);
  endfunction
endclass
module top;
  C h;
  initial begin h = new; h.show(); end
endmodule
