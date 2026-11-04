// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, output logic o);
   localparam int P = 3;
   mod m(.a(v[P]));
   assign o = v[0];
endmodule
