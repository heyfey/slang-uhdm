// concat-under-arithmetic imported params, QUALIFIED reads only (no import)
package pk;
  localparam logic [7:0] P_ADD = 100 + 100;
  localparam logic [7:0] P_CADD = {4'h1, 4'h2} + 1;
  localparam logic [7:0] P_COR = {4'h1, 4'h2} | 8'h0F;
  localparam logic [7:0] P_NEG = -{4'h1, 4'h2};
  localparam logic [7:0] P_RADD = {2{4'h1}} + 1;
  localparam logic [7:0] P_NEST = ({4'h1, 4'h2} + 1) * 2;
  localparam logic [7:0] P_CAT = {4'h1, 4'h2};
endpackage
module top (output logic [7:0] a, b, c);
  assign a = pk::P_CADD;
  assign b = pk::P_COR;
  assign c = pk::P_ADD;
endmodule
