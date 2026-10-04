// § decode N (N0254): uvm_resource_types' enum pair with a property of the class itself written with the enum
package p;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
    override_e ov;
  endclass
endpackage
