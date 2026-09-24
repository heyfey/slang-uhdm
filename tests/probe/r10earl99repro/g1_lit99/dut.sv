// r10earl99 g1 -- LITERAL x TARGET WIDTH, every member of one struct set from
// a CONT_ASSIGN TERNARY ARM.  Widths 1/4/32/64/65/parameterized; literals
// '1 '0 'x 'z 1'b1 4'hF a parameter a concat.
package q99;
  parameter int PW = 12;
  parameter logic [3:0] P4 = 4'hA;
  typedef struct packed {
    logic          w1;
    logic [3:0]    w4;
    logic [31:0]   w32;
    logic [63:0]   w64;
    logic [64:0]   w65;
    logic [PW-1:0] wp;
    logic [7:0]    w8a;
    logic [7:0]    w8b;
  } wide_t;
endpackage

module g1_lit99 (
  input  logic       sel,
  input  q99::wide_t in_d,
  output q99::wide_t o1,
  output q99::wide_t o0,
  output q99::wide_t ox,
  output q99::wide_t oz,
  output q99::wide_t om
);
  assign o1 = sel ? in_d :
              '{w1:'1, w4:'1, w32:'1, w64:'1, w65:'1, wp:'1, w8a:'1, w8b:'1};
  assign o0 = sel ? in_d :
              '{w1:'0, w4:'0, w32:'0, w64:'0, w65:'0, wp:'0, w8a:'0, w8b:'0};
  assign ox = sel ? in_d :
              '{w1:'x, w4:'x, w32:'x, w64:'x, w65:'x, wp:'x, w8a:'x, w8b:'x};
  assign oz = sel ? in_d :
              '{w1:'z, w4:'z, w32:'z, w64:'z, w65:'z, wp:'z, w8a:'z, w8b:'z};
  // MIXED: sized / based / parameter / concat literals must be left ALONE.
  assign om = sel ? in_d :
              '{w1:1'b1, w4:4'hF, w32:32'd7, w64:'1, w65:'0,
                wp:q99::P4, w8a:{4'h3,4'h6}, w8b:'x};
endmodule
