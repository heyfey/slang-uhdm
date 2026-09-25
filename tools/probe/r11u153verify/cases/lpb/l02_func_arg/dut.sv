// § lpBoundOperandKeepsBase145v
module dut(input logic [31:0] a, output logic [3:0] o);
  localparam int L = 4;
  function automatic logic [3:0] f(logic [3:0] x); return x; endfunction
  if (1) begin : g
    assign o = f(a[7:L]);
  end
endmodule
