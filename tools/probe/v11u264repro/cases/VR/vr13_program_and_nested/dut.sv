// § elabParamRefSignedTsUnlocated264
module sub #(parameter int W = 3) (output logic [31:0] o);
  localparam int A = W;
  localparam int B = A;
  wire [B-1:0] n = '1;
  assign o = n + B;
  assign imp = n[0];
endmodule
module top(output logic [31:0] o, output logic [31:0] p);
  sub u(.o(o));
  sub #(.W(5)) v(.o(p));
endmodule
