// § classScopeTdPkgListingParent214 — a class-scope specialization typedef inside a package class (r10uvm112 a8's shape), no importer
package pbox;
  class Box #(type Q = int, string Nm = "?"); int b; endclass
endpackage
package puse;
  import pbox::*;
  class solo;
    typedef Box #(solo, "solo") sid;
  endclass
endpackage
