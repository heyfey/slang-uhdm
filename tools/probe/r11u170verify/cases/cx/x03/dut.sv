// § implNetBareParamElab160 § elabOvArrFoldSharesDefParamTs163
module leaf #(parameter int IFN = 4, parameter logic [IFN-1:0] DAM [2] = '{default: '0}, parameter logic P = 1'b1) (output logic [IFN-1:0] o, output logic p);
  assign w = P;
  assign p = w;
  assign o = DAM[0] | DAM[1];
endmodule
module top (output logic [3:0] o, output logic p);
  leaf #(.DAM('{4'b1x01, 4'b0010}), .P(1'b0)) l(.o(o), .p(p));
endmodule
