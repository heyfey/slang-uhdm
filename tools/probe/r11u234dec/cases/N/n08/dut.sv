// § decode N: n07 with a property written with the base typedef only
package p;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
    override_t ot;
  endclass
endpackage
