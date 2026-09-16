// r11u52 ROAD C — ELEMENT KINDS and DIM FORMS under one module-body typedef
// that carries an unpacked dimension.  The law under test folds/keeps the
// ELEMENT typespec's PACKED bounds; the wrapper's own unpacked bound is a
// different object.  Every row here is a separate typedef in one body.
module dut #(
    parameter int unsigned DATA_SIZE = 64,
    parameter int unsigned DEPTH     = 4,
    parameter int unsigned NDATA     = 2
) (
    output logic [NDATA-1:0] o
);
  typedef logic [NDATA-1:0]                a_t  [DEPTH];      // base (c1 up1_t)
  typedef logic signed [NDATA-1:0]         sg_t [DEPTH];      // SIGNED element
  typedef bit   [NDATA-1:0]                bt_t [DEPTH];      // bit element
  typedef logic [NDATA-1:0]                rr_t [DEPTH-1:0];  // RANGED unpacked dim
  typedef logic [3:0]                      li_t [DEPTH];      // LITERAL bound (control)
  typedef int                              it_t [DEPTH];      // no packed bound at all
  typedef logic [NDATA-1:0]                vec_t;             // named packed typedef
  typedef vec_t                            nm_t [DEPTH];      // element = NAMED typedef
  typedef logic [NDATA-1:0][DATA_SIZE-1:0] two_t [DEPTH];     // packed 2-D element
  a_t a; sg_t sg; bt_t bt; rr_t rr; li_t li; it_t it; nm_t nm; two_t tw;
  assign o = a[0] | sg[0] | {NDATA{bt[0][0]}} | rr[0] | {NDATA{li[0][0]}} |
             {NDATA{it[0][0]}} | nm[0] | tw[0][0][NDATA-1:0];
endmodule
