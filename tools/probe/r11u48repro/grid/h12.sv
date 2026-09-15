module h12 (input logic c, output logic o);
  localparam longint P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
