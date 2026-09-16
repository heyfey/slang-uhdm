// b1 — does the flag LEAK into buildStructTs?  A body typedef whose ELEMENT is a
// struct typedef routes through buildStructTs while unfoldedTypedefElemDims is
// set; that struct's own unpacked-array MEMBER bounds are minted by the same
// anonAggregateElemTs the law re-routes.
module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic [N-1:0] o
);
  // a struct with an UNPACKED-ARRAY member whose element carries a symbolic
  // packed bound -> anonAggregateElemTs at the struct-member site
  typedef struct {
    logic [N-1:0] pair [2];
    logic [N-1:0] scal;
  } st_t;

  // the element of THIS body typedef is the struct above: buildStructTs runs
  // with the law's flag on
  typedef st_t sarr_t [DEPTH];

  // a control: the same struct used WITHOUT an unpacked-dim typedef wrapper
  st_t plain;
  sarr_t sa;

  // the plain module-body head this law targets, for reference
  typedef logic [N-1:0] mem_t [DEPTH];
  mem_t mem;

  assign o = plain.scal;
endmodule
