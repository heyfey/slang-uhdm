// § decode N (N0254): n09 with a package-scope pair beside it (the package listing's enum over a package scalar typedef)
package p;
  typedef bit[1:0] pov_t;
  typedef enum pov_t { P_A = 2'b01, P_B = 2'b10 } pov_e;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
  endclass
endpackage
