// § methCallNameSpanAcrossLines244
package p;
  class cbk;
    virtual function void pre_read(int rw); endfunction
    virtual function int get(); return 1; endfunction
    function cbk nxt(); return this; endfunction
    cbk nx; int q[$];
  endclass
  class user;
    function void run(cbk cb);
      int z;
      cb .pre_read(1);
      cb . pre_read(2);
      cb	.	pre_read(3);
      z = cb .get();
      z = cb
          .get() + cb.
          get();
      cb.nx .pre_read(4);
      cb.nxt() .pre_read(5);
      z = cb.q .size();
      cb.q .push_back(z);
      z = cb.nx. get;
    endfunction
  endclass
endpackage
module top; p::user u; initial u = new(); endmodule
