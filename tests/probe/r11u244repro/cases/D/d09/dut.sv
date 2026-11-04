// § methCallNameSpanAcrossLines244
package p;
  class cbk;
    virtual function void pre_read(int rw); endfunction
    virtual function int get(); return 1; endfunction
    cbk nx;
    int arr[4];
  endclass
  class user;
    cbk mcb;
    function void run(cbk cb);
      int rw;
      int z;
      rw = 1;
      z = cb. get;
    endfunction
  endclass
endpackage
module top;
  p::user u;
  initial u = new();

endmodule
