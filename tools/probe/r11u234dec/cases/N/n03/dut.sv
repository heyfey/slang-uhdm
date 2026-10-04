// § decode N: n01 with the class referenced by a property written with the enum (types::override_e)
package p;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
  endclass
  class pool;
    types::override_e ov;
  endclass
endpackage
