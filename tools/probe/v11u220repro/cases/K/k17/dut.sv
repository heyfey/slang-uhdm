// § strLitContLineSpan220
module top(output logic [63:0] o);
  for (genvar g = 0; g < 2; g++) begin : gen
    logic [63:0] w;
    assign w = "gn\
x";
  end
  assign o = gen[1].w;
endmodule
