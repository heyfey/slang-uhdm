// § decode N (N0254): uvm_resource_types' shape, a class-scope enum typedef whose base is a class-scope scalar typedef, beside a second enum typedef another class uses
package p;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
    typedef enum { PRI_HIGH, PRI_LOW } priority_e;
  endclass
  class pool;
    function void f(types::priority_e pri);
    endfunction
  endclass
endpackage
