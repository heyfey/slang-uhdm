package p1;
  class base;
    extern virtual task run(string name, int unsigned n = 3);
  endclass
  task base::run(string name, int unsigned n = 3);
    #1;
  endtask
endpackage
module top;
  import p1::*;
  base b;
  initial begin b = new; b.run("a"); end
endmodule
