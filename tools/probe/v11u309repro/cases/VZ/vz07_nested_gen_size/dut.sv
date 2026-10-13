// § defGenModArraySizeRange309
module leaf (input logic i, output logic o);
  assign o = ~i;
endmodule
module top (input logic [3:0] i, output logic [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : gf
    if (1) begin : gi
      leaf l [2] (.i(i[2*k+1:2*k]), .o(o[2*k+1:2*k]));
    end
  end
endmodule
