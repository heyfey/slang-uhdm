// § modUnpackedDimArithRef405
module m #(parameter int n = 2, parameter logic [7:0] a [n-1:0] = '{default: 8'h1}) (output logic [7:0] o);
  assign o = a[0];
endmodule
module top (output logic [7:0] o, output logic [7:0] p);
  m u(o);
  m #(.n(3), .a('{8'h1, 8'h2, 8'h3})) v(p);
endmodule
