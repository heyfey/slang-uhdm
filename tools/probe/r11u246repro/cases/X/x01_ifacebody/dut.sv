// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [7:0] d; } k_t;
  typedef struct packed { k_t [3:0] key; logic v; } s_t;
endpackage
interface ifc import hp::*; ();
  wire s_t w;
  assign w.key[1].d = '1;
  function automatic int f(); static int n; n++; return n; endfunction
  function automatic int g(); return f.n; endfunction
endinterface
module top;
  ifc i();
  assign undeclared_imp = 1'b1;
  wire [1:0] r = {i.w.key[1].d[0], 1'b0};
endmodule
