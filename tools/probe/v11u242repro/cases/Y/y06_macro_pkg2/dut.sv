// § impArrParamTsOwnRanges242
// The array declared through a macro, bounds from another package, imported into a module with a parameter port list and read in a param default of the importer.
package base;
  parameter int LEN = 2;
endpackage
`define DECL_ARR(n, w) parameter logic [w-1:0] n [base::LEN] = '{w'(1), w'(2)};
package hp;
  `DECL_ARR(ARR, 6)
endpackage
module core import hp::*; #(parameter logic [5:0] D = ARR[1]) (input logic i, output logic [5:0] o);
  assign o = ARR[i] ^ D;
endmodule
module top (input logic i, output logic [5:0] o);
  core u (.i(i), .o(o));
endmodule
