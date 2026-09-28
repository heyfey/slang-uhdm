// § aliasOfTdSharedKeepsModName183: an alias in package q of a typedef of package p, used as a struct member in q and read in a module that imports q
package p;
  typedef logic [7:0] byte_t;
endpackage
package q;
  typedef p::byte_t qbyte_t;
  typedef struct packed { qbyte_t d; logic v; } pkt_t;
endpackage
module top (input q::pkt_t a, output logic [7:0] o);
  import q::*;
  assign o = a.d;
endmodule
