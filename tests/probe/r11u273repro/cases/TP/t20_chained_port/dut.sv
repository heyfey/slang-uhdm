// § typeParamStructLastNetParent273
module dut #(
    parameter type s_t = struct packed { logic [7:0] a; logic b; },
    parameter type t_t = s_t
) ( input t_t i, output logic o );
  assign o = ^{i};
endmodule
