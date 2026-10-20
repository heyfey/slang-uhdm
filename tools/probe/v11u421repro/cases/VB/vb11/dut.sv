// § bitsDefNoFoldNoTs421
module top (output logic [7:0] o);
  function automatic int f(); return 3; endfunction
  localparam W = $bits(f());
  assign o = W;
endmodule
