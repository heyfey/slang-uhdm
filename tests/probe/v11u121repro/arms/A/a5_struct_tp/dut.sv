typedef struct packed { logic [1:0] a; logic b; } st_t;
module dut #(parameter type T = st_t) (input logic s, input logic [3:0] v, output logic [7:0] y [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign y[k] = s ? T'(v[k+:3]) : T'({v[0], v[1]});
  end
endmodule
