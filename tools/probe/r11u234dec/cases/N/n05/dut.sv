// § decode N (N0254): uvm_resource_types' whole body, used through its class-handle typedef by another class's formal
package p;
  class q #(type T=int);
    T items[$];
  endclass
  class rbase; endclass
  class types;
    typedef bit[1:0] override_t;
    typedef enum override_t { TYPE_OVERRIDE = 2'b01,
                              NAME_OVERRIDE = 2'b10 } override_e;
    typedef q#(rbase) rsrc_q_t;
    typedef enum { PRI_HIGH, PRI_LOW } priority_e;
    typedef struct
    {
      time read_time;
      int unsigned read_count;
    } access_t;
  endclass
  class pool;
    function void f(types::rsrc_q_t rq);
    endfunction
  endclass
endpackage
