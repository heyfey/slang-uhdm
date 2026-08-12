// r10svs4repro/g3_assoc.sv — grid arm 3: the shapes the ONE other corpus test
// that contains a this-rooted indexed select would present if it were live.
//
// Rggen (`rggen_backdoor_pkg.sv:15,34`) has exactly two such sites, BOTH behind
// `\`ifdef RGGEN_ENABLE_BACKDOOR`, which Rggen.sl never defines -- so they are
// dead today.  They are STRING-KEYED ASSOCIATIVE-array lvalues, and one of them
// has a `new(...)` on the right, which is r10svs3's landed
// § thisSuperNewAssignNoStmt3.  Measuring them here is what makes the claim
// "the law's gate is the written `this` and NOT the index kind" honest for the
// index kind this corpus actually carries besides int, rather than assumed.
class Wrap;
   int v;
   function new(int v); this.v = v; endfunction
endclass

class Store;
   int   vif[string];             // string-keyed associative array
   Wrap  wrapper[string];
   int   iv[int];                 // int-keyed associative array

   function void set(string hdl_path, int vif);
      string path;
      path = hdl_path;
      this.vif[path] = vif;             // e1 LVALUE assoc[string], this
      this.wrapper[path] = new(vif);    // e2 LVALUE assoc[string] = new(...)
      this.iv[3] = vif;                 // e3 LVALUE assoc[int const], this
   endfunction

   function int get(string hdl_path);
      return this.vif[hdl_path];        // e4 RVALUE assoc[string], this in return
   endfunction

   function int getbare(string hdl_path);
      return vif[hdl_path];             // e5 RVALUE assoc, NO receiver written
   endfunction

   function void other(Store o, string p);
      o.vif[p] = 1;                     // e6 LVALUE assoc, HANDLE receiver
   endfunction
endclass

module m3;
   initial begin end
endmodule
