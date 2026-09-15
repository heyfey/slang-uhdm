// vb7 — `byte` / `shortint` / `longint` / `integer`: NOT in the switch.
module vb7 (input logic c, output logic o);
  localparam byte     P1 = 4;
  localparam shortint P2 = 4;
  localparam longint  P3 = 4;
  localparam integer  P4 = 4;
  logic [P1:0] x1; logic [P2:0] x2; logic [P3:0] x3; logic [P4:0] x4;
  assign o = c ^ x1[0] ^ x2[0] ^ x3[0] ^ x4[0];
endmodule
