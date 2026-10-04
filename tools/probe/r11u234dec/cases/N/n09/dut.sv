// § decode N (N0254): n07 without the property: the class-scope enum typedef over a class-scope scalar typedef, unused
package p;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
  endclass
endpackage
