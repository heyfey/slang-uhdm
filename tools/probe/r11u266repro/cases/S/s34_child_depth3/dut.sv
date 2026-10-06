// § sgnLitElabFreshIntTs266
module leaf (output logic [63:0] o);
  localparam int P = 8'shF0;
  for (genvar c = 0; c < 1; c++) begin : g
    assign o = P + c;
  end
endmodule
module mid (output logic [63:0] o);
  leaf l (.o(o));
endmodule
module dut (output logic [63:0] o);
  mid m (.o(o));
endmodule
