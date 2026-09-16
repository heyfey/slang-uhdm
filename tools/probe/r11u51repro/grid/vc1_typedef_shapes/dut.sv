// VERIFIER arm (r11v51) — ROAD C, shapes the pass did not cut.  The map says
// the divergence trigger is "a typedef that carries an UNPACKED dimension" and
// that the producer's Reduce::No is hard at CompileModule.cpp:653.  If the
// trigger is really the unpacked dimension, then TWO unpacked dimensions, a
// STRUCT element with an unpacked dimension, and an unpacked-dimension typedef
// inside a GENERATE block must all behave the same way as c1's mem_t.
module dut #(
    parameter int unsigned DATA_SIZE = 64,
    parameter int unsigned DEPTH     = 4,
    parameter int unsigned NDATA     = 2
) (
    output logic [NDATA-1:0] o
);
  typedef logic [NDATA-1:0] two_t [DEPTH][2];              // TWO unpacked dims
  typedef struct packed { logic [NDATA-1:0] f; } sp_t;
  typedef sp_t sarr_t [DEPTH];                             // struct + unpacked
  typedef logic [NDATA-1:0][DATA_SIZE-1:0] pk2_t;          // packed 2-D, no unpacked
  two_t   t2;
  sarr_t  sa;
  pk2_t   p2;
  logic [NDATA-1:0] gsel;
  if (DEPTH > 0) begin : g
    typedef logic [NDATA-1:0] gen_t [DEPTH];               // inside a GENERATE block
    gen_t ga;
    assign gsel = ga[0];
  end
  assign o = t2[0][0] | sa[0].f | p2[0][NDATA-1:0] | gsel;
endmodule
