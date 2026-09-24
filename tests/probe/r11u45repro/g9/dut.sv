// g9 — the chain among module BODY localparams (not the header list).
module dut ( input logic [2:0] i, output logic o );
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t;
  b_t x;
  assign x = i;
  assign o = ^x;
endmodule
