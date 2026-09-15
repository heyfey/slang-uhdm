// g5 — the chained-FROM parameter's default is an ANONYMOUS ENUM.
module dut #(
    parameter type e_t = enum logic [1:0] { A, B, C },
    parameter type f_t = e_t
) ( input f_t i, output logic o );
  assign o = ^i;
endmodule
