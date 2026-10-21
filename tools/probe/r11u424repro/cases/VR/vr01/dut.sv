// § defGenConnVarSelRange424 (bsg_mul_array shape)
module m #(parameter w = 2) (output [w-1:0] p); endmodule
module top (output logic [3:0][4:0] prod_accum);
  genvar i;
  for (i = 0; i < 1; i++) begin : first_row
    m #(.w(i+2)) u (.p(prod_accum[i][i+1:0]));
  end
endmodule
