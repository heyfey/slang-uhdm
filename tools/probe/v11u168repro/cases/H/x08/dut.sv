// § hcSelIdxInstName168
module mod(input logic a, input logic b);
endmodule
module dut(input logic [7:0] v, input logic [7:0] w, input logic [2:0] i);
   mod m(.a(v[i]), .b(w[i]));
   mod n(.a(w[i]), .b(v[i]));
endmodule
