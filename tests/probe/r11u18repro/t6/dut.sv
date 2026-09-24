// t6: CLASS type parameters and a GENERATE-scope type parameter re-pass.
class cls #(parameter type CT = int, localparam type CLT = byte);
  CT a; CLT b;
  function int f(); return 0; endfunction
endclass
module leaf #(parameter type GT = int) (output logic o);
  GT a; assign o = |{a};
endmodule
module dut(output logic o);
  logic [1:0] w;
  for (genvar g = 0; g < 2; g++) begin : gb
    leaf #(.GT(logic [g:0])) u (.o(w[g]));
  end
  assign o = ^w;
endmodule
