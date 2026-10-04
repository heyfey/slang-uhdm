// § decode N: n01 with the first enum's base written as a keyword vector (no base typedef)
package p;
  class types;
    typedef enum bit[1:0] { TYPE_OVERRIDE = 2'b01,
                            NAME_OVERRIDE = 2'b10 } override_e;
    typedef enum { PRI_HIGH, PRI_LOW } priority_e;
  endclass
  class pool;
    function void f(types::priority_e pri);
    endfunction
  endclass
endpackage
