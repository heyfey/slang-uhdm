// § arrQueryParamArgOnly158v
module sub (input logic [6:2] p, output logic [7:0] o);
  localparam int R = $right(p);
  assign o = R;
endmodule
module top (input logic [4:0] a, output logic [7:0] o); sub u(.p(a), .o(o)); endmodule
