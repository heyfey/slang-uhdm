// § methCallNameSpanAcrossLines244
`define CALL(O, M) O.M
`define CALLS(O, M) O. M
`define DO_CB(T, METHOD) begin T cb; cb = new(); cb.METHOD; end
package p;
  class cbk;
    virtual function void pre_read(int rw); endfunction
    virtual function int get(); return 1; endfunction
  endclass
  class user;
    function void run(cbk cb);
      int z;
      `CALL(cb, pre_read(1));
      `CALLS(cb, pre_read(2));
      z = `CALL(cb, get());
      `DO_CB(cbk,
         pre_read(3))
      `DO_CB(cbk, pre_read(4))
    endfunction
  endclass
endpackage
module top; p::user u; initial u = new(); endmodule
