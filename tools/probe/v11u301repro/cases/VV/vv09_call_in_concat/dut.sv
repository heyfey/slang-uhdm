// § caConstVarFoldNeedsReducibleInit301
module child (output logic [15:0] o);
  function automatic logic [7:0] mk(); return 8'd2; endfunction
  logic [15:0] w = {mk(), 8'd1};
  assign o = w;
endmodule
module dut (output logic [15:0] o);
  child u (.o(o));
endmodule
