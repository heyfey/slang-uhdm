// § callOpArgNotReadEither276v
module sub #(parameter logic [11:0] K = 12'h001) (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  assign o = f(K + 12'h1);
endmodule
module dut (output logic [31:0] o, p);
  sub a (.o(o));
  sub #(.K(12'h0F0)) b (.o(p));
endmodule
