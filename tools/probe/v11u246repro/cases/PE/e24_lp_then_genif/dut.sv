// § callArgCopyEvalCtxAbstain246v
module sub #(parameter int N = 2) (output logic [N-1:0][7:0] o, output logic [7:0] q);
  function automatic bit [N-1:0][7:0] f(int n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i + 1);
    return r;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  assign o = L;
  localparam int Z = L[1];
  if (Z == 2) begin : g
    assign q = 8'd5;
  end else begin : h
    assign q = 8'd6;
  end
endmodule
module top(output logic [2:0][7:0] o, output logic [7:0] q);
  sub #(.N(3)) u(.o(o), .q(q));
endmodule
