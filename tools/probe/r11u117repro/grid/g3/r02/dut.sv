// concat-under-arithmetic imported params read in cont-assigns (unqualified)
package pk;
  localparam logic [7:0] P_ADD = 100 + 100;
  localparam logic [7:0] P_CADD = {4'h1, 4'h2} + 1;
  localparam logic [7:0] P_COR = {4'h1, 4'h2} | 8'h0F;
  localparam logic [7:0] P_NEG = -{4'h1, 4'h2};
  localparam logic [7:0] P_RADD = {2{4'h1}} + 1;
  localparam logic [7:0] P_NEST = ({4'h1, 4'h2} + 1) * 2;
  localparam logic [7:0] P_CAT = {4'h1, 4'h2};
endpackage
module top import pk::*; (output logic [7:0] a, b, c, d, e, f, g);
  assign a = P_ADD;
  assign b = P_CADD;
  assign c = P_COR;
  assign d = P_NEG;
  assign e = P_RADD;
  assign f = P_NEST;
  assign g = P_CAT;
endmodule
