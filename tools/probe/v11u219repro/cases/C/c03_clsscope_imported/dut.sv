// § classScopeTdPkgListingParent214 — a class-scope specialization typedef inside a package class, the package imported by a module and an interface
package pk;
  class Box #(type T = int, string N = "b"); T v; endclass
  class solo;
    typedef Box #(solo, "solo") sid_t;
    sid_t h;
  endclass
endpackage
interface ifc;
  import pk::*;
  solo s;
endinterface
module top;
  import pk::*;
  ifc u();
  solo t;
endmodule
