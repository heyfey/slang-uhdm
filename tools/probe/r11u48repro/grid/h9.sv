// h9 — `byte`: slang says SIGNED, but valueRange's three-kind switch does not
// name byte_typespec.  Separates "slang-signed" from "valueRange-captured".
module h9 (input logic c, output logic o);
  localparam byte P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
