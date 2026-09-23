module dut #(parameter type id_t = logic [1:0]) (input logic [3:0] a, output logic [3:0] o);
  (* keep *) id_t [1:0] x;
  assign x = a;
  assign o = x;
endmodule
