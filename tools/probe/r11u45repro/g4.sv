// g4 — the chained-FROM parameter's default is an ANONYMOUS PACKED STRUCT
// (port_chained_type_param's shape).
module dut #(
    parameter type s_t = struct packed { logic [7:0] a; logic b; },
    parameter type t_t = s_t
) ( input t_t i, output logic o );
  assign o = ^{i};
endmodule
