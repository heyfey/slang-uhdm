// r10uvm100 arm a2 -- STATEMENT delays inside CLASS methods (the head's home),
// including a fork/begin body, a named begin, an out-of-block body, and three
// live instances so DEF and ELAB copies are both scored.
package p2a;
  int gtime = 4;
  class c2a;
    int q;
    task automatic run(int stop_timeout);
      if (stop_timeout == 0)
        q = 1;
      #(stop_timeout)
      q = 2;
      #stop_timeout q = 3;
      #6 q = 4;
      fork begin
        #(stop_timeout)
        q = 5;
      end join_none
      begin : nb
        #(gtime + 1) q = 6;
      end
    endtask
    extern task oob(int t2);
  endclass
  task c2a::oob(int t2);
    #(t2) q = 7;
    #t2 q = 8;
  endtask
  task automatic pk2(int t3);
    #(t3) gtime = t3;
    #t3 gtime = 0;
  endtask
endpackage
module m2a;
  import p2a::*;
  c2a i1, i2, i3;
  initial begin
    i1 = new(); i2 = new(); i3 = new();
    i1.run(1); i2.run(2); i3.run(3);
    pk2(5);
  end
endmodule
