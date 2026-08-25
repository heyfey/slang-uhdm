// r10uvm136 arm C — PROPERTY KIND x the same packed-struct typedef.
package Pk3;
  typedef struct packed { bit [7:0] MIN_A; bit [7:0] max_b; int unsigned stride3; } addr_span_t;
  typedef struct { int deep; } soft_span_t;

  class ManyShapes55;
    addr_span_t             c01_plain;
    static addr_span_t      c02_static;
    rand addr_span_t        c03_rand;
    randc bit [2:0]         c04_randcbits;
    local addr_span_t       c05_local;
    protected addr_span_t   c06_prot;
    const addr_span_t       c07_const = '0;
    addr_span_t             c08_fixed[3];
    addr_span_t             c09_queue[$];
    addr_span_t             c10_dyn[];
    addr_span_t             c11_assoc[string];
    soft_span_t             c12_softplain;
    soft_span_t             c13_softqueue[$];
    addr_span_t             c14_two, c15_three;
  endclass
endpackage

module ctop;
  Pk3::ManyShapes55 m55;
  initial m55 = new();
endmodule
