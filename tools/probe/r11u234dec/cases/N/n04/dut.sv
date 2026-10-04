// § decode N: n01 with the typedef-based enum itself used by the other class (types::override_e)
package p;
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
  endclass
  class pool;
    function void f(types::override_e ov);
    endfunction
  endclass
endpackage
