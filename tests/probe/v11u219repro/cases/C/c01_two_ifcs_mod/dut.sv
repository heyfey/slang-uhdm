// § classTdAliasLastWriter214 — a package class specialization typedef aliased by a second one, imported by two interfaces and a module (the module writes last)
package p;
  class box #(type T = int); T v; endclass
  typedef box #(int) ibox_t;
  typedef box #(int) ibox2_t;
endpackage
interface ifa;
  import p::*;
  ibox2_t a;
endinterface
interface ifz;
  import p::*;
  ibox2_t z;
endinterface
module top;
  import p::*;
  ifa ua();
  ifz uz();
  ibox2_t m;
endmodule
