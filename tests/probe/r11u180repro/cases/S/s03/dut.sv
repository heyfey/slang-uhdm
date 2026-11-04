// § elabPatQualRefQualSpan133 (the sister site, decode only)
module top #(parameter int W = 8) (input logic a_i, output logic [W-1:0] b_o);
  typedef struct packed {
    logic [W-1:0] S_SW;
    logic [W-1:0] M_SW;
  } it_t;
  localparam it_t INT = '{ S_SW: 1, M_SW: 3 };
  assign b_o = a_i ? INT.S_SW : INT.M_SW;
endmodule
