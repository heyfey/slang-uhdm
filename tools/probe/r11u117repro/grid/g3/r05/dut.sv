// imported params used as a module parameter default and a localparam init
package pk;
  localparam logic [7:0] P_ADD = 100 + 100;
  localparam logic [7:0] P_CADD = {4'h1, 4'h2} + 1;
  localparam logic [7:0] P_COR = {4'h1, 4'h2} | 8'h0F;
  localparam logic [7:0] P_NEG = -{4'h1, 4'h2};
  localparam logic [7:0] P_RADD = {2{4'h1}} + 1;
  localparam logic [7:0] P_NEST = ({4'h1, 4'h2} + 1) * 2;
  localparam logic [7:0] P_CAT = {4'h1, 4'h2};
endpackage
module top import pk::*; #(parameter logic [7:0] Q = P_CADD) (output logic [7:0] a, b);
  localparam logic [7:0] L = P_COR + 1;
  assign a = Q;
  assign b = L;
endmodule
