// § memberBareTdAliasNamedByUse183: a nested struct in a package (an inner struct member typed by the typedef), a package variable of it, and a module variable through a qualified name
package p;
  typedef bit [15:0] addr_t;
  typedef struct { addr_t lo; addr_t hi; } rng_t;
  typedef struct { rng_t r; addr_t base; } map_t;
  map_t gmap;
endpackage
module top;
  p::map_t lm;
endmodule
