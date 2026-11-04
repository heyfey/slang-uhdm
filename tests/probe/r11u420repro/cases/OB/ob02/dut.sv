// § modOutOfBodyMethodIsModuleTf420
module tb;
  class c;
    int a, b;
    extern function int sum(int k);
    extern task t(int k);
  endclass
  function int c::sum(int k);
    int loc;
    loc = a + b + k;
    return loc;
  endfunction
  task c::t(int k);
    a = k;
  endtask
  c h;
  initial begin h = new; h.t(1); $display(h.sum(2)); end
endmodule
