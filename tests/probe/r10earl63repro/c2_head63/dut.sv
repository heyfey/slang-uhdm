// r10earl63 — THE HEAD IN 17 LINES: earl62 R0 (prim_ram_1p_adv.sv:32) reduced to
// one file.  golden ELAB param_assign Rhs for Aw: INT:14 ct 7 "14" vpiSize 32.
// MEASUREMENT ONLY.
function automatic integer vbits(integer value);
  return (value == 1) ? 1 : $clog2(value);
endfunction

module sub #(
  parameter int Depth = 512,
  localparam int Aw = vbits(Depth)
) (
  input logic [Aw-1:0] a_i,
  output logic o
);
  assign o = |a_i;
endmodule

module top(input logic [13:0] a, output logic o);
  sub #(.Depth(16384)) u_sub (.a_i(a), .o(o));
endmodule
