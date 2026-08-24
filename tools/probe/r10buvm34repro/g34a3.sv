// r10buvm34repro/g34a3.sv — ARM 3: HOMES.  The same scoped and bare foreach
// pair in an IN-BODY class method, a STATIC class method, a PACKAGE FREE
// FUNCTION, a package TASK, a MODULE initial, a module TASK, an ALWAYS block,
// an INTERFACE function, a PROGRAM initial, a fork...join_none and a
// CONSTRAINT-free class in a module — the four home shapes the brief names
// plus the ones `writePackage` does NOT run `lateTypedefBinding` over.
// MEASUREMENT ONLY.
package r34;

  class kx34;
    int k;
  endclass

  class hom34;
    typedef hom34 this_type;
    static int    sq34 [$];
    static string ss34 [$];
    static int    sa34 [string];
    int           iq34 [$];
    // IN-BODY home
    function void inb34();
      int rr34;
      foreach (this_type::sq34[i]) rr34 = i;     // I1 scoped queue<int>
      foreach (this_type::ss34[i]) rr34 = i;     // I2 scoped queue<string>
      foreach (this_type::sa34[i]) rr34 = 1;     // I3 scoped assoc[string]
      foreach (sq34[i])            rr34 = i;     // I4 bare control
      foreach (ss34[i])            rr34 = i;     // I5 bare control
      foreach (sa34[i])            rr34 = 1;     // I6 bare control
    endfunction
    // STATIC-METHOD home
    static function void stat34();
      int rr34;
      foreach (this_type::ss34[i]) rr34 = i;     // X1 scoped
      foreach (ss34[i])            rr34 = i;     // X2 bare
    endfunction
  endclass

  string pv34 [$];

  // PACKAGE FREE FUNCTION home
  function void pfun34();
    int rr34;
    foreach (hom34::ss34[i]) rr34 = i;           // P1 scoped, class qualifier
    foreach (r34::pv34[i])   rr34 = i;           // P2 scoped, PACKAGE qualifier
    foreach (pv34[i])        rr34 = i;           // P3 bare control
  endfunction

  // PACKAGE TASK home
  task ptask34();
    int rr34;
    foreach (hom34::ss34[i]) rr34 = i;           // K1 scoped
    foreach (pv34[i])        rr34 = i;           // K2 bare control
  endtask

endpackage

interface if34;
  import r34::*;
  string iv34 [$];
  // INTERFACE FUNCTION home
  function void ifun34();
    int rr34;
    foreach (hom34::ss34[i]) rr34 = i;           // F1 scoped
    foreach (iv34[i])        rr34 = i;           // F2 bare control
  endfunction
endinterface

program pgm34;
  import r34::*;
  string gv34 [$];
  // PROGRAM home
  initial begin
    int rr34;
    foreach (hom34::ss34[i]) rr34 = i;           // G1 scoped
    foreach (gv34[i])        rr34 = i;           // G2 bare control
  end
endprogram

module top34a3;
  import r34::*;
  string mv34 [$];
  int    mi34 [$];
  // MODULE INITIAL home
  initial begin
    int rr34;
    foreach (hom34::ss34[i]) rr34 = i;           // M1 scoped, class qualifier
    foreach (r34::pv34[i])   rr34 = i;           // M2 scoped, package qualifier
    foreach (mv34[i])        rr34 = i;           // M3 bare control
  end
  // MODULE TASK home
  task mtask34();
    int rr34;
    foreach (hom34::ss34[i]) rr34 = i;           // N1 scoped
    foreach (mv34[i])        rr34 = i;           // N2 bare control
  endtask
  // ALWAYS home
  always @(*) begin
    int rr34;
    foreach (hom34::ss34[i]) rr34 = i;           // W1 scoped
    foreach (mi34[i])        rr34 = i;           // W2 bare control
  end
  // FORK home
  initial fork
    begin
      int rr34;
      foreach (hom34::ss34[i]) rr34 = i;         // J1 scoped
      foreach (mv34[i])        rr34 = i;         // J2 bare control
    end
  join_none
endmodule
