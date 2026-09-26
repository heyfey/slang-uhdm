// § defNetEndOutputCol171
`define STR(x) `"x`"
`define WW 12
module dut (input logic [11:0] i, output logic [11:0] o);
  localparam string N = `STR(abc); logic [`WW-1:0] q [2];
  assign q[1] = i;
  assign o = q[1];
endmodule
