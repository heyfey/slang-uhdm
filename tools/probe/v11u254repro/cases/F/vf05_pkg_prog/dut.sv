// § forInitSelectLhsBase254 (in a package function, a program block and an interface body)
typedef struct { int a; } s_t;
package fp;
  typedef struct { int a; } s_t;
  function automatic int pf(); s_t s; int n = 0; for (s.a = 0; s.a < 2; s.a++) n++; return n; endfunction
endpackage
interface ifb; int n; s_t s; initial begin for (s.a = 0; s.a < 2; s.a++) n++; end endinterface
program prg; s_t s; int n; initial begin for (s.a = 0; s.a < 2; s.a++) n++; end endprogram
module top(output int o); ifb i(); initial o = fp::pf(); endmodule
