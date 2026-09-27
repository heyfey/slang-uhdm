// § doWhileSpansToCloseParen175 § doWhileEndsAtCondEnd178v
package p;
  class c;
    int q [string];
    task t();
      string key;
      int n = 0;
      if (q.first(key))
        do begin
          n++;
        end while (q.next(key));
    endtask
  endclass
endpackage
module top; import p::*; c o; initial begin o = new; o.t(); end endmodule
