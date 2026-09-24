// h5 — a plain literal localparam: isolates THE FOLD.
module h5 (input logic c, output logic o);
  localparam int P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
