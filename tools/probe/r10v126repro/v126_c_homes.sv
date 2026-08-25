// r10v126 arm C - HOMES the implementer's grid B omits: an INTERFACE variable,
// an interface TASK local, a $unit (compilation-unit) function local, a nested
// for-loop block local, a fork/join block local, and a class INSIDE a package
// with THREE distinct instantiations.
interface if126v;
  string  ifStr126v [2];          // interface variable
  real    ifRea126v [3];
  task ifTsk126v();               // interface task local
  string  itStr126v [4];
  chandle itHnd126v [5];
  shortreal itSrl126v [6];
  event   itEvt126v [7];
  itStr126v[3]="i"; itHnd126v[4]=null; itSrl126v[5]=1.5;
  endtask
endinterface

// $unit-scope function
function automatic int unitFn126v();
  string  unStr126v [8];
  longint unLng126v [2];
  unStr126v[7]="u"; unLng126v[1]=64'd4;
  return 0;
endfunction

package pk_hm126v;
  class Deep126v;
    task loops();
      int idx126v;
      for (int k126v = 0; k126v < 2; k126v++) begin : lp126v
        string  lpStr126v [3];
        integer lpInt126v [4];
        lpStr126v[2]="l"; lpInt126v[3]=7;
      end
      fork
        begin : fk126v
          string  fkStr126v [5];
          time    fkTim126v [2];
          fkStr126v[4]="f"; fkTim126v[1]=9;
        end
      join_none
      idx126v = 0;
    endtask
  endclass
endpackage

module m126v;
  if126v u_if126v();
  pk_hm126v::Deep126v d1_126v, d2_126v, d3_126v;
  initial begin
    d1_126v = new(); d2_126v = new(); d3_126v = new();
    d1_126v.loops(); d2_126v.loops(); d3_126v.loops();
    void'(unitFn126v());
    u_if126v.ifTsk126v();
  end
endmodule
