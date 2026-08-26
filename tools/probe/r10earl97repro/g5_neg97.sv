// r10earl97 g5 -- NEGATIVE CONTROLS.  Cast widths that must NOT gain a
// VpiSigned: an UNTYPED localparam (Surelog's buildIntTypespec mints a NAMED
// int_typespec and never touches VpiSigned), a literal width, and a cast whose
// target is a TYPE rather than a width.
module top5n97;
  logic [31:0] o;
  sub5n97 u_s(.o(o));
endmodule
module sub5n97 (output logic [31:0] o);
  logic [3:0] m;
  localparam UNTYPED_W = 5;            // no type keyword at all
  localparam int TYPED_W = 5;
  typedef logic [7:0] byte_t97;
  assign o = 32'(UNTYPED_W'(m)) + 32'(8'(m)) + 32'(byte_t97'(m)) + 32'(TYPED_W'(m));
endmodule
