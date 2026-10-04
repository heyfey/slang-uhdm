// § decode N (N0254): uvm_resource_types' enum pair, the class reached through a struct typedef another class's property uses (types::access_t access[string])
package p;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
    typedef struct
    {
      time read_time;
      int unsigned read_count;
    } access_t;
  endclass
  class rbase;
    types::access_t access[string];
  endclass
endpackage
