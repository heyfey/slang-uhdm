// § methCallNameSpanAcrossLines244
package p;
  class cbk;
    virtual function void pre_read(int rw); endfunction
    virtual function int get(); return 1; endfunction
    cbk nx;
  endclass
  class user;
    function void run(cbk cb);
      int rw;
      int z;
      rw = 1;
      cb
        .pre_read(rw);
    endfunction
  endclass
endpackage
module top;
  p::user u;
  initial u = new();
endmodule
