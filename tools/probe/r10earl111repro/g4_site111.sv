// r10earl111 arm g4 -- THE FOLD-SITE MATRIX.  ONE parameter (`int unsigned`,
// module body), read in every select slot this campaign has a law for.  The
// rows that are NOT the indexed part-select's WIDTH belong to OTHER passes --
// § psBoundPkgParamTs31 owns the part_select bounds, § hpConnElemIdxFold17 the
// element index, § elabHierSelWidthFold the base half -- and every one of them
// must stay BYTE-IDENTICAL across this patch.  That is what makes this arm a
// boundary, not a demonstration.
package pk4111;
  typedef struct packed { logic [31:0] src; logic v; } h_t;
endpackage

module s4111 (input pk4111::h_t h_i, input pk4111::h_t a_i [4],
              output logic [63:0] o);
  localparam int unsigned W = 2;
  logic [63:0] r;
  for (genvar gi = 0; gi < 1; gi++) begin : gb
    assign r[ 1: 0] = h_i.src[0 +: W];        // c1 IPS WIDTH  <- THIS LAW
    assign r[ 3: 2] = h_i.src[W +: 2];        // c2 IPS BASE
    assign r[ 5: 4] = h_i.src[W-1 : 0];       // c3 part_select LEFT bound
    assign r[ 7: 6] = h_i.src[1 : W-2];       // c4 part_select RIGHT bound
    assign r[ 9: 8] = {1'b0, h_i.src[W]};     // c5 bit_select INDEX
    assign r[11:10] = a_i[W].src[0 +: 2];     // c6 element index of an array
    assign r[13:12] = a_i[W].src[0 +: W];     // c7 index AND width together
  end
  assign o = r;
endmodule

module g4_site111;
  pk4111::h_t s;
  pk4111::h_t aa [4];
  logic [63:0] oo;
  s4111 u (.h_i(s), .a_i(aa), .o(oo));
endmodule
