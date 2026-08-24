// r10vbuvm34repro/v34c.sv — VERIFIER ARM C: HOMES the implementer's g34a3 did
// not reach — GENERATE (for / if), a module with the IDENTICAL text as a twin,
// 1..3 instances, a class declared in a MODULE and in $unit, and a loop
// variable that SHADOWS a class property.  MEASUREMENT ONLY.
package rc34;
  class cc34;
    typedef cc34 this_type;
    static int    sq34 [$];
    static int    sa34 [string];
    static int    i;            // a property NAMED like a loop variable
    static int    sf34 [4];
    extern function void oob34();
  endclass
  // OOB method whose loop variable SHADOWS the property `i`
  function void cc34::oob34();
    int r;
    foreach (this_type::sq34[i]) r = i;      // SH1 loop var shadows property i
    foreach (sq34[i])            r = i;      // SH2 bare twin
  endfunction
endpackage

module gen34 #(parameter int N = 2) ();
  import rc34::*;
  int r34;
  genvar g;
  generate
    for (g = 0; g < N; g++) begin : gl34
      initial begin
        foreach (cc34::sq34[i]) r34 = i;     // G1 generate-for, scoped
        foreach (cc34::sa34[i]) r34 = 1;     // G2 generate-for, scoped assoc
      end
    end
    if (N > 1) begin : gi34
      initial begin
        foreach (cc34::sf34[i]) r34 = i;     // G3 generate-if, scoped
      end
    end
  endgenerate
endmodule

// twin A and twin B carry IDENTICAL body text under different names
module twinA34;
  import rc34::*;
  int r34;
  initial begin
    foreach (cc34::sq34[i]) r34 = i;
    foreach (cc34::sa34[i]) r34 = 1;
    foreach (cc34::sf34[i]) r34 = i;
  end
endmodule
module twinB34;
  import rc34::*;
  int r34;
  initial begin
    foreach (cc34::sq34[i]) r34 = i;
    foreach (cc34::sa34[i]) r34 = 1;
    foreach (cc34::sf34[i]) r34 = i;
  end
endmodule

class uc34;               // a class in $unit
  typedef uc34 this_type;
  static int uq34 [$];
  static int ua34 [string];
endclass

module unit34;
  int r34;
  initial begin
    foreach (uc34::uq34[i]) r34 = i;         // UN1 $unit class, scoped
    foreach (uc34::ua34[i]) r34 = 1;         // UN2
  end
endmodule

module topc34;
  gen34 #(3) g3();
  gen34 #(1) g1();
  twinA34 ta();
  twinB34 tb();
  unit34  un1();
  unit34  un2();
endmodule
