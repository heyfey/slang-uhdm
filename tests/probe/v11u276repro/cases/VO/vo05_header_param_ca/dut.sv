// § elabRhsOwnTsNotDefFormal276
module sub #(parameter logic [11:0] K = 12'h00F) (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); return x; endfunction
  assign o = f(K);
endmodule
module dut (output logic [31:0] o, output logic [31:0] p);
  sub a (.o(o));
  sub #(.K(12'h0F0)) b (.o(p));
endmodule
