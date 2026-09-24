// r10earl31 arm e1 — THE POSITION THE WITNESS SITS IN: a package-parameter fold
// used as a PART-SELECT RANGE BOUND, inside a PROCESS, read QUALIFIED, in a
// module that does NOT import the package (exactly Earlgrey's dm_csrs.sv, which
// has no `import` at all — every dm:: read there is qualified).
//
// cells (line:col of the folded constant is the cell key):
//   o1  r.data[pk::DC-1:0]        THE EARLGREY WITNESS: hier_path part_select,
//                                 inside a cast, bound arithmetic one op deep
//   o2  r.data[pk::PB-1+16:16]    the dm_csrs.sv:409 shape: TWO ops deep
//   o3  d[pk::DC-1:0]             plain (non-hier) part_select, one op deep
//   o4  d[pk::DC:0]               BARE bound — the constant's parent IS the select
//   o5  d[7:pk::DC]               the RIGHT bound
//   o6  d[pk::DC+4:pk::DC]        BOTH bounds folded in one select
//   o7  d[pk::DC-1:0]             no cast around the select
//   o8  $clog2(pk::DC)            NEGATIVE CONTROL — vo.sv row F says a bound
//                                 fold under a SYS-FUNC CALL carries no stamp
//   o9  unnamed always_comb       the FULLNAME axis: is the prefix the block?
//   o10 inside a FUNCTION body    the subroutine axis
//   o11 cont_assign bound         the EXISTING § caPartSelBoundFoldTs rule, but
//                                 with NO import — does it fire on a qualified
//                                 read of a package this module never imports?
package pk;
  localparam logic [3:0] DC = 4'h2;
  localparam logic [4:0] PB = 5'h8;
  typedef struct packed {
    logic [6:0]  addr;
    logic [31:0] data;
  } req_t;
endpackage

module e1 (
  input  logic [31:0] d,
  input  pk::req_t    r,
  output logic [31:0] y,
  output logic [31:0] z
);
  logic [31:0] a1, a2, a3, a4, a5, a6, a7, a8, a9, aa;

  always_comb begin : blk
    a1 = 12'(r.data[pk::DC-1:0]);          // o1
    a2 = 32'(r.data[pk::PB-1+16:16]);      // o2
    a3 = 32'(d[pk::DC-1:0]);               // o3
    a4 = 32'(d[pk::DC:0]);                 // o4
    a5 = 32'(d[7:pk::DC]);                 // o5
    a6 = 32'(d[pk::DC+4:pk::DC]);          // o6
    a7 = d[pk::DC-1:0];                    // o7
    a8 = 32'(d[$clog2(pk::DC)+1:0]);       // o8
  end

  always_comb begin
    a9 = 32'(d[pk::DC-1:0]);               // o9  (unnamed block)
  end

  function automatic [31:0] f1(input logic [31:0] w);
    f1 = 32'(w[pk::DC-1:0]);               // o10
  endfunction

  assign aa = 32'(d[pk::DC-1:0]);          // o11
  assign y  = a1 ^ a2 ^ a3 ^ a4 ^ a5 ^ a6 ^ a7 ^ a8 ^ a9 ^ aa;
  assign z  = f1(d);

  // o12/o13 — the hier_path select with NO bound arithmetic (the fold's parent
  // IS the select) and with the fold on the RIGHT bound.  Added after the first
  // patched run: the fullname formula turned out to depend on WHICH PREFIX the
  // emitter is carrying when it descends into the bound, and that differs
  // between the direct-bound and the through-an-operation descent, so the
  // hier_path half needed its own zero-operation cell instead of an assumption.
  logic [31:0] ac, ad;
  always_comb begin : blk2
    ac = 32'(r.data[pk::DC:0]);            // o12
    ad = 32'(r.data[7:pk::DC]);            // o13
  end
endmodule
