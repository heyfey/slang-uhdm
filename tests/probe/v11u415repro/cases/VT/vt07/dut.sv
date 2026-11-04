// § thisCallResultMemberDropped415
class C;
  int s = 2;
  function C mk();
    C o = new;
    return o;
  endfunction
  task run(output int r);
    if (this.mk().s > 1) r = this.mk().s;
    else r = 0;
  endtask
endclass
module top(output int r);
  C h;
  initial begin h = new; h.run(r); end
endmodule
