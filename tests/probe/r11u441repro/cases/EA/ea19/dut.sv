// § sysCallEmptyArgEndPrevTok441
module top #(parameter N = 2);
  logic [3:0] a;
  for (genvar i = 0; i < N; i++) begin : g
    always @(a) $display("x", a[i],
                          , i);
  end
endmodule
