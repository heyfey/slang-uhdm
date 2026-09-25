// § arrQueryParamArgOnly158v
module top (input logic [9:3] v, output logic [7:0] o);
  logic [0:5] w;
  localparam int H = $high(v);
  localparam int L = $left(w);
  assign w = '0;
  assign o = H + L;
endmodule
