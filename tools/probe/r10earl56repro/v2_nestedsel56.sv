// r10earl56 VERIFIER arm v2 — THE PARENT-KIND BATTERY.  The fence keys on
// `parent->UhdmType() == part_select || indexed_part_select`.  Every shape here
// puts the gen-scope param reference in a position whose UHDM PARENT is
// something else, or is a part_select that is NOT the "direct bound of the
// cont-assign's own select": nested selects, casts, parentheses, concatenation
// bounds, a bit_select index, and a bound that is a select of a param.
module v2_sub56 #(parameter int unsigned Depth = 4)
                (input logic [31:0] din, input logic [31:0] idx,
                 output logic [31:0] o);
  if (Depth != 0) begin : gen_n
    localparam int unsigned PN = 3;
    localparam int unsigned QN = 4;
    logic [31:0] s1, s2, s3, s4, s5, s6, s7, s8, s9, s10;

    // inner select IS the bound of the outer select -> the ref's parent is the
    // INNER part_select / indexed_part_select
    assign s1  = {28'b0, din[ idx[PN:1] +: 4]};    // inner psel LEFT, d0
    assign s2  = {28'b0, din[ idx[0 +: PN] +: 4]}; // inner ips WIDTH, d0
    assign s3  = {28'b0, din[ idx[PN] +: 4]};      // inner bit_select INDEX, d0

    // an explicit CAST around the bound
    assign s4  = {29'b0, din[0 +: int'(PN)]};
    // PARENTHESISED (syntactically wrapped, same expression)
    assign s5  = {29'b0, din[0 +: (PN)]};
    // a CONCATENATION as the bound
    assign s6  = {28'b0, din[0 +: {1'b0, PN[1:0]}]};
    // the param SELECTED, so the ref is a bit/part select's base not the bound
    assign s7  = {29'b0, din[0 +: PN[1:0]]};
    // the OPERATION control (README axis 2)
    assign s8  = {29'b0, din[PN-1:0]};
    // TWO gen-scope params, one each side of a bare psel
    assign s9  = {28'b0, din[QN:PN]};
    // ips with BOTH base and width gen-scope params
    assign s10 = {28'b0, din[PN +: QN]};

    assign o = s1^s2^s3^s4^s5^s6^s7^s8^s9^s10;
  end
endmodule

module v2_nestedsel56 (input logic [31:0] din, input logic [31:0] idx,
                       output logic [31:0] o1);
  v2_sub56 #(.Depth(4)) u_s (.din(din), .idx(idx), .o(o1));
endmodule
