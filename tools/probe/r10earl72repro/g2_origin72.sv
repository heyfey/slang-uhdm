// r10earl72 g2 — ORIGIN x HOME grid for § caOpFoldTs's ELAB half.
// The SAME position (a multi-concat repeat count under one `&` operation —
// the Earlgrey head shape) with the symbol's ORIGIN varied, and the same
// package read placed in every HOME an instance body offers.  The negative
// controls are the point: a module parameter, a module localparam, a gen-scope
// localparam, a genvar and a QUALIFIED package read must NOT gain a stamp.
package g2p;
  parameter int NB = 4;
  parameter bit [7:0] TB = 8'd3;
  parameter     UT = 5;
endpackage

module g2m import g2p::*; #(
  parameter int MP = 2
) (
  input  logic req_i,
  output logic [15:0] o_i
);
  localparam int ML = 3;
  logic [15:0] buf_alloc;

  // O1 wildcard-imported package int parameter (the head origin)
  logic [15:0] o1; assign o1 = {NB{req_i}} & buf_alloc;
  // O2 the SAME package parameter read QUALIFIED
  logic [15:0] o2; assign o2 = {g2p::NB{req_i}} & buf_alloc;
  // O3 a package parameter with an EXPLICIT packed type
  logic [15:0] o3; assign o3 = {TB{req_i}} & buf_alloc;
  // O4 a package parameter with an IMPLICIT type
  logic [15:0] o4; assign o4 = {UT{req_i}} & buf_alloc;
  // O5 a MODULE parameter (negative control)
  logic [15:0] o5; assign o5 = {MP{req_i}} & buf_alloc;
  // O6 a MODULE localparam (negative control)
  logic [15:0] o6; assign o6 = {ML{req_i}} & buf_alloc;

  // H1 inside a gen-for body
  for (genvar i = 0; i < 2; i++) begin : gen_h1
    localparam int GL = 2;
    logic [15:0] h1; assign h1 = {NB{req_i}} & buf_alloc;
    // H2 a GEN-SCOPE localparam (negative control)
    logic [15:0] h2; assign h2 = {GL{req_i}} & buf_alloc;
    // H3 the GENVAR itself (negative control)
    logic [15:0] h3; assign h3 = {(i+1){req_i}} & buf_alloc;
    // H4 nested gen
    for (genvar j = 0; j < 2; j++) begin : gen_h4
      logic [15:0] h4; assign h4 = {NB{req_i}} & buf_alloc;
    end
  end

  assign o_i = o1 | o2 | o3 | o4 | o5 | o6;
endmodule

module g2top;
  logic r; logic [15:0] a, b, c;
  // three instances of the same module: does every ELAB body stamp?
  g2m       u0(.req_i(r), .o_i(a));
  g2m #(.MP(7)) u1(.req_i(r), .o_i(b));
  g2m #(.MP(9)) u2(.req_i(r), .o_i(c));
endmodule
