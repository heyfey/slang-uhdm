// § classScopeTdPkgListingParent214 — j01 with a module importing the using package
package pbox;
  class Box #(type Q = int, string Nm = "?"); int b; endclass
endpackage
package puse;
  import pbox::*;
  class solo;
    typedef Box #(solo, "solo") sid;
  endclass
endpackage
module top;
  import puse::*;
endmodule
