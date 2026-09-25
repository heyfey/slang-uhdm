// § elabOvArrFoldSharesDefParamTs163
module leaf #(parameter int IFN = 4, parameter logic [IFN-1:0] DAM [2] = '{default: '0}) (output logic [IFN-1:0] o);
  assign o = DAM[0] ^ DAM[1];
endmodule
module mid #(parameter int W = 4) (output logic [W-1:0] o);
  leaf #(.IFN(W), .DAM('{4'b10x1, 4'b0110})) l(.o(o));
endmodule
module top (output logic [3:0] o); mid m(.o(o)); endmodule
