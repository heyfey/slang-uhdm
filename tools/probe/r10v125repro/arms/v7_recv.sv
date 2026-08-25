// v125 arm V7 — RECEIVERS: class handle, chained handle, static method, virtual
// method, super., this., and an interface/modport task, all with a converting
// output actual.
interface Iface_Bus;
  logic [63:0] busReg;
  task automatic fetch(output logic [63:0] d); d = busReg; endtask
  modport mp (import fetch);
endinterface

package Recv_Pkg;
  typedef logic [63:0] Reg64;
  class Base_Cls;
    virtual function int vGrab(output Reg64 v); v = 64'd1; return 0; endfunction
    static  function int sGrab(output Reg64 v); v = 64'd2; return 0; endfunction
    function int bGrab(output Reg64 v); v = 64'd3; return 0; endfunction
  endclass
  class Mid_Cls extends Base_Cls;
    Base_Cls inner;
    function int useSuper(output Reg64 v); return super.bGrab(v); endfunction
  endclass
  class Chain_Cls;
    Mid_Cls mid;
    logic [15:0] tiny;
    int          rc;
    function void go();
      Base_Cls bh;
      rc = bh.vGrab(tiny);          // virtual method, converting
      rc = bh.bGrab(tiny);          // plain method, converting
      rc = Base_Cls::sGrab(tiny);   // static method, converting
      rc = mid.inner.bGrab(tiny);   // CHAINED receiver, converting
      rc = mid.useSuper(tiny);      // super. inside the callee
      rc = this.mid.inner.bGrab(this.tiny); // this.-rooted both ends
    endfunction
  endclass
endpackage

module Recv_Leaf (Iface_Bus.mp ifp);
  logic [15:0] shortSig;
  initial ifp.fetch(shortSig);
endmodule

module Recv_Top;
  Iface_Bus theBus();
  Recv_Leaf u_leaf (.ifp(theBus.mp));
endmodule
