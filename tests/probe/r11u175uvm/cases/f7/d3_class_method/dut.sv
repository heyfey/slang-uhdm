package p1;
  class c;
    int q[string];
    function void f();
      string key;
      if (q.first(key))
        do begin
          q[key] = 1;
        end while(q.next(key));
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  c o;
  initial begin o = new; o.f(); end
endmodule
