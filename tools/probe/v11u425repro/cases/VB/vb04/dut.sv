// § oneTickUpperBNormalized425
primitive dff_u (q, d, clk);
  output q; reg q;
  input d, clk;
  initial q = 1'B1;
  table
    ? r : ? : 1;
    ? f : ? : -;
  endtable
endprimitive
module top(input logic d, input logic clk, output logic q);
  dff_u u(q, d, clk);
endmodule
