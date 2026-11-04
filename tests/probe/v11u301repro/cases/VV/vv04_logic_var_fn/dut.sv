// § caConstVarFoldNeedsReducibleInit301
module child (output logic [7:0] o);
  function automatic logic [7:0] mk(); return 8'd9; endfunction
  logic [7:0] w = mk();
  assign o = w;
endmodule
module dut (output logic [7:0] o);
  child u (.o(o));
endmodule
