// § defGenLpSelIdxThroughBase424 (pass 421 residue rd01)
module top #(parameter dims_p = 2, parameter int P [dims_p:0] = '{5,4,0}) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < dims_p; i=i+1) begin: rof
    localparam A = P[i+1];
    localparam B = P[i];
    assign o[i] = A > B;
  end
endmodule
