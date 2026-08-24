// r10vbuvm33 v33c.sv — HOMES and POSITIONS.  A generate block, a fork/join,
// a final block, an interface initial, a class CONSTRAINT foreach, a task in
// a package, a class in a MODULE, a class in $unit, a virtual class, an
// out-of-body method of a class declared in a MODULE, two instances of the
// same module, and the same foreach text inside a MODULE twin.
// MEASUREMENT ONLY.
package ph33;
  class src33;
    static int sq33 [$];
    static int sa33 [4];
  endclass
  int lint33;
  task automatic pt33();
    foreach (src33::sq33[i])            // H1  package TASK home
      lint33 = i;
  endtask
endpackage

class u33;                              // $unit-scope class
  static int uq33 [$];
  rand int rq33 [4];
  constraint c33 { foreach (rq33[i]) rq33[i] < 10; }
  constraint d33 { foreach (u33::rq33[i]) rq33[i] > 0; }   // H2 SCOPED in a constraint
endclass

virtual class v33;
  static int vq33 [$];
  pure virtual function void pv33();
endclass

module mod33 #(parameter int K = 0);
  import ph33::*;
  int lq33 [$];
  class incl33;                         // a class declared INSIDE a module
    static int cq33 [$];
    extern function void oob33();
  endclass
  function void incl33::oob33();
    foreach (incl33::cq33[i])           // H3  OOB of a class in a MODULE
      cq33.push_back(i);
    foreach (src33::sq33[i])            // H4  imported pkg class, module OOB
      cq33.push_back(i);
  endfunction
  initial begin
    fork
      begin
        foreach (src33::sq33[i])        // H5  FORK home
          lq33.push_back(i);
      end
    join_none
  end
  final begin
    foreach (src33::sa33[i])            // H6  FINAL home
      lq33.push_back(i);
  end
endmodule

interface iface33;
  import ph33::*;
  int iq33 [$];
  initial begin
    foreach (src33::sq33[i])            // H7  INTERFACE initial
      iq33.push_back(i);
  end
endinterface

module twin33;                          // the MODULE twin: identical text
  import ph33::*;
  int tq33 [$];
  initial begin
    foreach (src33::sq33[i])            // H8  MODULE twin
      tq33.push_back(i);
  end
endmodule

module top33c;
  import ph33::*;
  int gq33 [$];
  genvar gi33;
  mod33 #(.K(0)) a33 ();
  mod33 #(.K(1)) b33 ();
  iface33 if33i ();
  twin33  tw33i ();
  u33 uh33;
  generate
    for (gi33 = 0; gi33 < 2; gi33++) begin : gb33
      initial begin
        foreach (src33::sa33[i])        // H9  GENERATE home, two instances
          gq33.push_back(i);
      end
    end
  endgenerate
  initial begin
    foreach (v33::vq33[i])              // H10 VIRTUAL class qualifier
      gq33.push_back(i);
    foreach (u33::uq33[i])              // H11 $unit class qualifier
      gq33.push_back(i);
    foreach (gq33[i])                   // H12 bare control
      gq33.push_back(i);
  end
endmodule
