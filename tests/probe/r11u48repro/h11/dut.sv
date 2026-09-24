// h11 — `shortint` and h12 `longint`: the last two slang-signed kinds the
// switch does not name.
module h11 (input logic c, output logic o);
  localparam shortint P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
