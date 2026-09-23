module top #(parameter int N = 2) (input logic [31:0] a, output logic [3:0] y);
  function automatic int f(int v); return v + 1; endfunction
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*2;
    if (N > 1) begin : h
      assign y[i] = a[f(L)+1];
    end
  end
endmodule
