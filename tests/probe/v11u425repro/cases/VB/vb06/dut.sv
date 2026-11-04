// § oneTickUpperBNormalized425
module top(input logic a, output logic y, output logic z, output logic w, output logic [1:0] v);
  assign y = a & 1'BZ;
  assign z = a & 1'Bz;
  assign w = a & 'B1;
  assign v = {a, 1'sB1};
endmodule
