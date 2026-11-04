// § fnRetLitRhsSharesDefConst273
module dut (output logic [31:0] o);
  function automatic int f7(); return 7; endfunction
  if (1) begin : g
    logic [31:0] lv;
    assign lv = f7();
    assign o = lv;
  end
endmodule
