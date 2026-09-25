// § concatArrParamDefTs151
module top(output logic [3:0] o);
  parameter logic [3:0] A[2] = {4'h1, 4'h2};
  for (genvar k = 0; k < 1; k++) begin : g
    assign o = A[k];
  end
endmodule
