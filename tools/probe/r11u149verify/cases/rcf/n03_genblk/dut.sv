// § replCountFoldFile140
module dut #(parameter int N = 2) (input logic s, output logic [3:0] o);
  if (1) begin : g
    localparam logic [3:0] A [N] = '{N{4'h5}};
    assign o = A[s];
  end
endmodule
