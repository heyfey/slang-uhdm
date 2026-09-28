// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] a, output logic [7:0] o);
  logic [3:0] r;
  function automatic logic [3:0] f(logic [3:0] v);
    return v ^ 4'h5;
  endfunction
  assign r = a;
  sub u (.d(7'(r[3:0])), .o(o));
endmodule
