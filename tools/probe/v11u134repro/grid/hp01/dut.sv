// § tsHierPathElemNoName134
module sub #(parameter int N = 2) (output logic [N-1:0] o);
  assign o = '1;
endmodule
module top #(parameter type T = struct packed { int unsigned N; }, parameter T P = '{N: 3}) (output logic [5:0] o);
  sub #(.N(P.N)) u [P.N-2:0] (.o(o));
endmodule
