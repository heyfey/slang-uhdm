module inner #(parameter int unsigned NumPorts = 1, parameter int unsigned DataWidth = 8,
               parameter type data_t = logic [DataWidth-1:0])
  (input logic [NumPorts-1:0] we_i, input data_t [NumPorts-1:0] d_i, output data_t o);
  assign o = d_i[0];
endmodule
module top (input logic w, input logic [7:0] d, output logic [7:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    inner #(.NumPorts(1), .DataWidth(8)) u (.we_i(w), .d_i(d), .o(o));
  end
endmodule
