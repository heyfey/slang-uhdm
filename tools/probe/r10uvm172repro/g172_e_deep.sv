// r10uvm172 arm E — the ONE-DEEP chain (where the WRITTEN arguments survive),
// the this./super. roads, the subscripted base, and body DEPTH.
// MEASUREMENT ONLY.
package pj172;
  class ebase172;
    string  eq172[$];
    int     en172;
    function void epush172(string s); eq172.push_back(s); endfunction
  endclass

  class euser172 extends ebase172;
    ebase172 ehold172;
    string   emap172[string];

    function void efn172(); endfunction
    task     etk172(); endtask

    // e01/e02 — ONE-DEEP: the receiver IS the collapsing name and the call is
    // written directly on it, so Surelog's argListNode lands on the WRITTEN
    // list_of_arguments.
    function void eone172();
      string   efn172[$];      // shadows THIS class's function efn172
      ebase172 etk172;         // shadows THIS class's task etk172
      efn172.push_back("e01");        // e01 one-deep builtin, ONE argument
      etk172 = new();
      etk172.epush172("e02");         // e02 one-deep USER method, ONE argument
    endfunction

    // e03/e04 — the implicit-class-handle roads.
    function void ehandle172();
      this.eq172.push_back("e03");    // e03 this.
      super.eq172.push_back("e04");   // e04 super.
    endfunction

    // e05 — a SUBSCRIPTED base whose name collapses.
    function void esub172();
      ebase172 efn172[4];
      efn172[1] = new();
      efn172[1].eq172.push_back("e05");
    endfunction

    // e06..e09 — BODY DEPTH: the MiniAmiq site is inside a foreach body.
    function euser172 edepth172();
      int i172;
      edepth172 = new();
      edepth172.eq172.push_back("e06");         // e06 depth 0
      begin : nb172
        edepth172.eq172.push_back("e07");       // e07 named begin
      end
      for (i172 = 0; i172 < 2; i172++)
        edepth172.eq172.push_back("e08");       // e08 for body, no begin
      foreach (edepth172.eq172[i172]) begin
        edepth172.eq172.push_back("e09");       // e09 foreach begin
      end
      if (i172 > 0) begin
        edepth172.eq172.push_back("e10");       // e10 if begin
      end else begin
        edepth172.eq172.push_back("e11");       // e11 else begin
      end
      return edepth172;
    endfunction

    // e12 — a `with` clause on a collapsing ONE-DEEP receiver
    // (§ stmtBuiltinBodyIsBareRecvCall151's population, intersected).
    function void ewith172();
      int efn172[$];
      efn172.sort() with (item);
    endfunction
  endclass
endpackage

module tope172;
  import pj172::*;
  euser172 e172;
  initial begin
    e172 = new();
    e172.eone172();
    e172.ehandle172();
    e172.esub172();
    void'(e172.edepth172());
    e172.ewith172();
  end
endmodule
