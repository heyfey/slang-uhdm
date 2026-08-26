// r10v151 (VERIFIER) arm 3 — HOMES the implementer's arm C does not reach:
// a $unit (compilation-unit) class, a class declared INSIDE a module, inside a
// program and inside an interface, a NESTED class, a PARAMETERIZED class with
// TWO specializations, and a module instantiated THREE times.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
class UnitCls3;                       // $unit scope
  int uq[$];
  bit ub[$];
  task ut3;
    uq.sort() with ( item );
    ub.or();
  endtask
endclass
package Ppk3;
  class Par3 #(int W = 4);
    int pq[$];
    bit pb[$];
    task pt3;
      pq.find_last() with ( item > W );
      pb.xor();
    endtask
  endclass
  class Outer3;
    typedef class Inner3;
    class Inner3;
      int nq[$];
      task nt3;
        nq.rsort() with ( item );
        nq.unique();
      endtask
    endclass
    int oq[$];
    Inner3 ins;
    task ot3; oq.sort() with ( item ); endtask
  endclass
endpackage
module Mhome3;
  import Ppk3::*;
  class InMod3;
    int mq[$];
    bit mb[$];
    task mt3;
      mq.sort() with ( item );
      mb.and();
    endtask
  endclass
  Par3 #(4) p4;
  Par3 #(9) p9;
  int  wq[$];
  initial begin
    wq.sort() with ( item );
  end
endmodule
program Phome3;
  class InPrg3;
    int gq[$];
    task gt3;
      gq.find_first() with ( item != 0 );
      gq.unique();
    endtask
  endclass
endprogram
interface Ihome3;
  class InIfc3;
    int fq[$];
    bit fb[$];
    task ft3;
      fq.sort() with ( item );
      fb.or();
    endtask
  endclass
endinterface
module Top3;
  Mhome3 u_one3();
  Mhome3 u_two3();
  Mhome3 u_three3();
  Ihome3 u_ifc3();
endmodule
