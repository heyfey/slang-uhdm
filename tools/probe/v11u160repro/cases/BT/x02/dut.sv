// § bodyTypeParamDefaultBound160
module top #(parameter type my_t = logic [3:0]) (input logic [15:0] d, output logic [15:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    localparam type my_t = struct packed { logic [7:0] a; logic [7:0] b; };
    my_t [0:0] arr;
    assign arr = d;
    assign o = arr;
  end
endmodule
