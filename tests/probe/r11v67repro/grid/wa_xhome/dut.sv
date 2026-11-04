// wa_xhome -- $unit typedef over a PACKAGE name, and a package typedef over a
// $unit name: both are "written over a NAMED type" in a never-rebound home.
package pk;
  typedef logic [1:0] cv_t;
endpackage
typedef logic [1:0] uv_t;
typedef pk::cv_t    uq_t;
module wa;
  uq_t   y01;
  wire uq_t y02;
endmodule
