// wc24.sv — pass-24 residue (1), the ENCODING half.  wa24/wb24 established
// WHERE golden keeps the ref (a NESTED elab gen scope, unqualified read); this
// file asks WHAT the fresh loc-less enum_const it binds there carries, over
// five package-parameter spellings: based hex, based binary, plain decimal
// typed, plain decimal UNTYPED, and an EXPRESSION initializer.
package r24;
  parameter logic [11:0] R_HEX = 12'h5A0;
  parameter logic [7:0]  R_BIN = 8'b1010_0001;
  parameter int unsigned R_DEC = 7;
  parameter              R_UNT = 12;
  parameter logic [11:0] R_EXP = R_HEX + 12'h010;
endpackage

module cc24
  import r24::*;
#(
  parameter bit En = 1'b1
) (
  input  logic [11:0] addr,
  input  logic        we,
  output logic [4:0]  o
);
  if (En) begin : g_o
    logic [4:0] r;
    for (genvar i = 0; i < 1; i++) begin : g_i
      assign r[0] = we & (addr == R_HEX);
      assign r[1] = we & (addr[7:0] == R_BIN);
      assign r[2] = we & (addr == R_DEC);
      assign r[3] = we & (addr == R_UNT);
      assign r[4] = we & (addr == R_EXP);
    end
    assign o = r;
  end
endmodule

module wc24 (
  input  logic [11:0] addr,
  input  logic        we,
  output logic [4:0]  o
);
  cc24 #(.En(1'b1)) u_c (.addr(addr), .we(we), .o(o));
endmodule
