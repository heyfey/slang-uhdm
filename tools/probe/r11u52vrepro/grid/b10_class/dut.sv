// b10 — the CLASS arm MUST STAY.  unfoldedTypedefDims (the class flag) and the
// new unfoldedTypedefElemDims are separate, but both end up in
// buildUnpackedArrayTypedefTs / anonAggregateElemTs.  A class typedef with an
// unpacked dimension and a symbolic element bound sits beside the module-body
// twin; the class cells must be byte-identical before and after.
// (A class PROPERTY of unpacked-array-typedef type is an UNTRANSLATABLE in our
// exporter at the base — rc 4 — so the properties are omitted and only the
// typedefs are declared, which is what the class arm of the law reaches.)
class C #(parameter int SIZE = 8);
  typedef logic [SIZE-1:0] cmem_t [4];
  typedef logic [SIZE-1:0][1:0] c2_t [SIZE-1:0];
  logic [SIZE-1:0] plain;
  function new(); plain = '0; endfunction
endclass

module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic o
);
  typedef logic [N-1:0] mmem_t [DEPTH];
  mmem_t mm;
  C #(6) c1inst;
  initial c1inst = new();
  assign o = mm[0][0];
endmodule
