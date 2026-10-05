// § impArrParamTsOwnRanges242
// The array declared through a macro, imported into a module with a parameter port list and read in a parameter default.
`define DECL_ARR(n, w) parameter logic [w-1:0] n [2] = '{w'(1), w'(2)};
package hp;
  `DECL_ARR(ARR, 6)
endpackage
module core import hp::*; #(parameter logic [5:0] D = ARR[1]) (input logic i, output logic [5:0] o);
  assign o = ARR[i] ^ D;
endmodule
module top (input logic i, output logic [5:0] o);
  core u (.i(i), .o(o));
endmodule
