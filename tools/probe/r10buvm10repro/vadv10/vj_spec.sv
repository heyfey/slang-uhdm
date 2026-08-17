// verifier arm J -- the chained0 branch reached through a PARAMETERIZED class:
// a typedef whose TARGET is a type PARAMETER makes chained0 true, so the enum
// base binds sharedAliasTs's object.  Two specializations of the same class ask
// whether that object is shared across them.
package pj10;
  typedef bit [3:0] tj_a;
  typedef bit [7:0] tj_b;
  typedef tj_a      tj_a_c;
endpackage
class cj10 #(parameter type PT = pj10::tj_a);
  typedef PT           tp_alias;          // target IS a type parameter
  typedef enum tp_alias { S0 = 0, S1 = 1 } e_spec;
  typedef enum PT       { T0 = 0, T1 = 1 } e_direct;
  e_spec   a;
  e_direct b;
endclass
class ck10;
  typedef pj10::tj_a_c ck_c;              // class alias of a PACKAGE chain
  typedef enum ck_c { U0 = 0, U1 = 1 } e_ck;
  e_ck z;
endclass
module vjTop10;
  cj10 #(pj10::tj_a) h1;
  cj10 #(pj10::tj_b) h2;
  cj10 #(pj10::tj_a_c) h3;
  ck10 h4;
endmodule
