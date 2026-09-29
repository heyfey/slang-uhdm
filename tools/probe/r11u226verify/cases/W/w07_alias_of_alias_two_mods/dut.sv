// § enumTdLastWriter214 — an alias of an alias of a package enum read by two modules named against declaration order and an interface
package p;
  typedef enum logic [1:0] {Q0, Q1, Q2} q_e;
  typedef q_e Q1_T;
  typedef Q1_T Q2_T;
endpackage
interface bus_i;
  import p::*;
  Q2_T b;
endinterface
module zz_m(output int o);
  import p::*;
  Q2_T z = Q2;
  assign o = int'(z);
endmodule
module aa_m(output int o);
  import p::*;
  Q1_T a = Q1;
  assign o = int'(a);
endmodule
module top(output int o1, output int o2);
  bus_i u_b();
  zz_m u_z(.o(o1));
  aa_m u_a(.o(o2));
endmodule
