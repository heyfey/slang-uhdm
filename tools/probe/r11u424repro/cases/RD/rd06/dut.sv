// § defGenLpSelIdxThroughBase424
module top #(parameter logic [7:0] V = 8'h5a) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 2; i++) begin : rof
    localparam bit A = V[i+1];
    localparam logic [1:0] B = V[2*i+1:2*i];
    assign o[i] = A ^ B[0];
  end
endmodule
