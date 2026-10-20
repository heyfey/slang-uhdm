// § thisCallResultMemberDropped415
class C;
  int s = 2;
  int t;
  function C mk();
    C o = new;
    return o;
  endfunction
  task run();
    t = this.mk().s + 1;
  endtask
endclass
module top;
  C h;
  initial begin h = new; h.run(); end
endmodule
