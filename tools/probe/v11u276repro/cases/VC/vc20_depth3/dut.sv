// § caUserCallRhsNotReduced276
module leaf #(parameter logic [11:0] K = 12'h001) (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); f = x; endfunction
  assign o = f(K);
endmodule
module mid #(parameter logic [11:0] K = 12'h002) (output logic [31:0] o); leaf #(.K(K)) l (.o(o)); endmodule
module dut (output logic [31:0] o); mid #(.K(12'h0AB)) m (.o(o)); endmodule
