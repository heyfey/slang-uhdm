module dut (input logic [7:0] a, output logic [7:0] o);
  (* keep *) logic [7:0] x;
  assign x = a;
  assign o = x;
endmodule
