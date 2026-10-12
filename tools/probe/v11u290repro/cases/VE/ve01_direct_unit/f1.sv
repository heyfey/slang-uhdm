// § caUnitEnumUnresolvedShares290
typedef enum logic { E_RD = 1'b0, E_WR = 1'b1 } cmd_e;
module m1(output logic o1);
assign o1 = E_WR;
endmodule
