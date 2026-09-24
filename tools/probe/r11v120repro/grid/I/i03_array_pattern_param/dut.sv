interface bus_if #(parameter int A [2] = '{3, 5});
  logic [A[0]-1:0] data;
  modport mp (input data);
endinterface
module reader #(parameter int ID = 0) (bus_if.mp s, output logic [31:0] w);
  assign w = s.A[0] + s.A[1] + ID;
endmodule
module top (output logic [31:0] w);
  bus_if #('{7, 9}) arr [2] ();
  reader #(.ID(1)) u (.s(arr[1]), .w(w));
endmodule
