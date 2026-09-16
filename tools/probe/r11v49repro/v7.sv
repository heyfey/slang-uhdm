// v11u49 arm v7 — LAW A fences re-cut: nested pattern element, positional,
// type key, on an UNPACKED package struct, each read scoped.
package p;
  typedef struct { logic [7:0] x; logic [7:0] y; } inner_t;
  typedef struct { inner_t ip; logic [7:0] k; } outer_t;
  typedef struct { logic [7:0] a; logic [7:0] b; } flat_t;
  localparam outer_t UNEST = '{ip:'{x:8'd1,y:8'd2}, k:8'd3};  // pattern-valued element
  localparam flat_t  UPOS  = '{8'd4, 8'd5};                   // positional
  localparam flat_t  UTYP  = '{default: 8'd6};                // default only
endpackage
module v7 (output logic [31:0] o);
  assign o = p::UNEST.k + p::UPOS.a + p::UTYP.b;
endmodule
