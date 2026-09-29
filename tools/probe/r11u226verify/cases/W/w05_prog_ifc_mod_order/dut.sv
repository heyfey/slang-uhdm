// § enumTdLastWriter214 — a program zz_p, an interface mm_i and a module aa_m import the package: interfaces and modules write after programs whatever the name order
package p;
  typedef enum logic [1:0] {K0, K1, K2} k_e;
  typedef k_e K_T;
endpackage
program zz_p;
  import p::*;
endprogram
interface mm_i;
  import p::*;
  K_T ik;
endinterface
module aa_m(output int o);
  import p::*;
  K_T mk = K2;
  assign o = int'(mk);
endmodule
module top(output int o);
  mm_i u_i();
  aa_m u_m(.o(o));
endmodule
