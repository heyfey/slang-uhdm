interface bus_if #(parameter int W = 8);
  logic [W-1:0] data;
  modport mp (input data);
endinterface
module reader (bus_if.mp s, output logic [31:0] w);
  assign w = 32'(s.W);
endmodule
module top (output logic [31:0] w);
  bus_if #(16) arr [1:0] ();
  reader u (.s(arr[0]), .w(w));
endmodule
