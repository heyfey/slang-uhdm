// § genElseIfGateTermPath171
primitive p_and (out, a, b);
  output out;
  input a, b;
  table
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive
module dut #(parameter int P = 2) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else if (P == 2) begin
    p_and u (c, a, b);
  end
endmodule
