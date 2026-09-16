// xb3 - concat under selects, casts, $bits and an index
package pk;
  parameter logic [1:0] C0 = 2'b01;
  parameter logic [1:0] C3 = 2'b11;
  // Z3: concat used as an INDEX
  parameter logic       Z3 = C3[{1'b0}];
  // Z4: $bits of a concat
  parameter int         Z4 = $bits({C0, C3});
  // Z5: concat under two casts
  parameter logic [3:0] Z5 = 4'(logic'(1) ? {C0, C3} : 4'd0);
  // Z6: signed cast over a concat
  parameter logic signed [3:0] Z6 = signed'({C0, C3});
  // Z7: element select of a replication
  parameter logic       Z7 = {2{C0}}[2];
  // Z8: concat inside a ternary CONDITION, ternary under a cast
  parameter logic [1:0] Z8 = 2'(({C0,C3} == 4'b0111) ? C0 : C3);
endpackage
module top;
  logic       a = pk::Z3 ^ pk::Z7;
  int         b = pk::Z4;
  logic [3:0] c = pk::Z5 ^ pk::Z6;
  logic [1:0] d = pk::Z8;
endmodule
