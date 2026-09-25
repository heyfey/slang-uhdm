// § foldedBoundTsRefUnstored144
module dut #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] y);
  function automatic logic [7:0] f(input logic [7:0] v);
    logic [P-1:0] t;
    t = v[P-1:0];
    return {4'b0, t};
  endfunction
  assign y = f(a);
endmodule
