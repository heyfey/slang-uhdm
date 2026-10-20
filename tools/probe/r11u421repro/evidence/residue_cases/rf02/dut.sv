// residue (no law landed): the elaborated port connection folds the select operands, see README
module m #(parameter w = 2) (input [w-1:0] d); endmodule
module top #(parameter width_p = 8, parameter c = 2) (input [width_p-1:0] di);
  m #(.w(c)) u (.d(di[(width_p-1)-:c]));
endmodule
