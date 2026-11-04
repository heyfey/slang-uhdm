// § elabRhsOwnTsNotDefFormal276
module dut (output logic [31:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  function automatic logic [31:0] f(e_t x); f = 32'(x); endfunction
  localparam e_t K = B;
  assign o = f(K);
endmodule
