// § genCaLhsIpsBoundCloneOnly282
module top #(parameter int P = 2) (input logic [3:0] a, output logic [7:0] o [2]);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [7:0] v;
    assign v[P +: 4] = f(4'd3);
    assign v[7:6] = '0; assign v[1:0] = '0;
    assign o[g] = v;
  end
endmodule
