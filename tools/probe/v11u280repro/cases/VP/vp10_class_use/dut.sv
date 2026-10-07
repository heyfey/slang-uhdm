// § pkgNetNamedTsDimEnd280
// a package class with a member of the typedef and a class-local array of it
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v [0:1];
  class c; st_t m; st_t arr [2]; endclass
endpackage
module top; pk::c h; initial h = new; endmodule
