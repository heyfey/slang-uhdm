// r11u90 w5 -- LAW B in a GENERATE scope.
module sub (output logic [31:0] o);
  parameter int D = 4;
  if (1) begin : g
    logic [31:0] c;
    assign #D c = 32'd10;
  end
  assign o = g.c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
