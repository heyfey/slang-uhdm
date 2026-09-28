// § memberBareTdAliasNamedByUse183: a package struct whose members are typed by bare scalar typedefs, used by two modules (wildcard and explicit import) and an instance of each
package p;
  typedef bit [7:0] id_t;
  typedef logic [3:0] len_t;
  typedef struct { id_t id; len_t len; id_t tag; } hdr_t;
endpackage
module a_m;
  import p::*;
  hdr_t h;
endmodule
module b_m;
  import p::hdr_t;
  hdr_t h2;
endmodule
module top;
  a_m ua ();
  b_m ub ();
endmodule
