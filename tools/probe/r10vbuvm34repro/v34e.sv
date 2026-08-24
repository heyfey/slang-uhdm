// r10vbuvm34repro/v34e.sv — VERIFIER ARM E: NESTED and REPEATED foreach over
// the same scoped array (the openForeachVars re-listing arm), a scoped foreach
// inside a class IN-BODY method, inside a static method, inside a fork, inside
// a while/for, and THREE instances of the same statement.  MEASUREMENT ONLY.
package se34;
  class ce34;
    typedef ce34 this_type;
    static int    sq34 [$];
    static int    s2d34[2][3];
    static int    sa34 [string];
    function void inbody34();                    // IN-BODY method
      int r;
      foreach (this_type::sq34[i]) r = i;        // N1
      foreach (this_type::sq34[i])               // N2 nested, same name
        foreach (this_type::s2d34[i,j]) r = i+j;
      foreach (this_type::sq34[i]) begin         // N3 same stmt, instance 1
        foreach (this_type::sa34[k]) r = 1;
      end
    endfunction
    static function void stat34();               // STATIC method
      int r;
      foreach (this_type::sq34[i]) r = i;        // N4
      foreach (this_type::sa34[i]) r = 1;        // N5
      foreach (sq34[i]) r = i;                   // N6 bare control
    endfunction
  endclass
endpackage

module me34;
  import se34::*;
  int r34;
  initial fork
    begin
      foreach (ce34::sq34[i]) r34 = i;           // F1 inside fork
    end
  join_none
  initial begin
    for (int q = 0; q < 2; q++)
      foreach (ce34::sq34[i]) r34 = i;           // F2 inside for
    while (r34 < 2)
      foreach (ce34::sa34[i]) r34 = 1;           // F3 inside while
    foreach (ce34::sq34[i]) r34 = i;             // F4 instance 1
    foreach (ce34::sq34[i]) r34 = i;             // F5 instance 2
    foreach (ce34::sq34[i]) r34 = i;             // F6 instance 3
  end
  always @(*) begin
    foreach (ce34::sq34[i]) r34 = i;             // F7 always
  end
endmodule
