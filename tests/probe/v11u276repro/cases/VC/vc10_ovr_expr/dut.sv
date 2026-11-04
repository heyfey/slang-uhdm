// § caUserCallRhsNotReduced276
module sub #(parameter logic [11:0] K = 12'h001) (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  assign o = f(K);
endmodule
module dut (output logic [31:0] o);
  localparam logic [11:0] A = 12'h010;
  sub #(.K(A + 12'h1)) u (.o(o));
endmodule
