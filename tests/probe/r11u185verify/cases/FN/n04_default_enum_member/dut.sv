// § refFullNameThroughNamedExpr175
package pa;
  typedef enum logic [1:0] {LO, MID, HI} lvl_e;
endpackage
interface ifc;
  import pa::*;
  function automatic int fi(lvl_e l = MID); return int'(l); endfunction
endinterface
package pb;
  import pa::*;
  class k; function int fc(lvl_e l = HI); return int'(l); endfunction endclass
endpackage
module top;
  import pa::*;
  function automatic int fm(lvl_e l = LO, lvl_e m = pa::HI); return int'(l) + int'(m); endfunction
  ifc u();
  pb::k o; int r;
  initial begin o = new; r = fm() + u.fi() + o.fc(); end
endmodule
