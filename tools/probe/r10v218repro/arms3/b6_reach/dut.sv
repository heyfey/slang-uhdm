// r10v218 arm b6 — REACHABILITY of `defAllInstCount[&def] == 0`.  Which
// interfaces count as "no instance elaborates it"?  Each sub-arm is a
// different distance from a real top-level instance.
interface if6v_inner;                    // instantiated ONLY inside an
   bit iv6v;                             // UNINSTANTIATED MODULE
   function void f6v(int a_a);
      int l6v;
      if (a_a == 1) iv6v = 1'b1;         // r01
      if (l6v == 1) iv6v = 1'b1;         // r02
      c6v(a_a);                          // r03
      c6v(l6v);                          // r04
   endfunction
   function void c6v(int z); endfunction
endinterface

module mod6v_never;                      // never instantiated
   if6v_inner u6v();                     // the only instance of if6v_inner
endmodule

interface if6v_host;                     // uninstantiated, and it INSTANTIATES
   bit hv6v;                             // another interface inside itself
   if6v_deep u6d();
   function void fh6v(int a_h);
      int lh6v;
      if (a_h == 1) hv6v = 1'b1;         // r05
      ch6v(lh6v);                        // r06
   endfunction
   function void ch6v(int z); endfunction
endinterface

interface if6v_deep;
   bit dv6v;
   function void fd6v(int a_d);
      int ld6v;
      if (a_d == 1) dv6v = 1'b1;         // r07
      cd6v(ld6v);                        // r08
   endfunction
   function void cd6v(int z); endfunction
endinterface

interface if6v_gen;                      // uninstantiated, GENERATE + CLOCKING
   parameter int G6V = 1;
   bit clk6v, gv6v;
   clocking cb6v @(posedge clk6v);
      input gv6v;
   endclocking
   generate
      if (G6V == 1) begin : g6v
         function void fg6v(int a_g);
            int lg6v;
            if (a_g == 1) gv6v = 1'b1;   // r09 gen-block fn, formal in a cond
            cg6v(lg6v);                  // r10 gen-block fn, local call arg
         endfunction
         function void cg6v(int z); endfunction
      end
   endgenerate
   function void ft6v(int a_t);
      int lt6v;
      if (a_t == 1) gv6v = 1'b1;         // r11 top-level fn, formal in a cond
      ct6v(lt6v);                        // r12 top-level fn, local call arg
   endfunction
   function void ct6v(int z); endfunction
endinterface

module top6v;
   initial begin end
endmodule
