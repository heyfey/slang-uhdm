// § psBoundBareRefByBase145
class C;
  localparam int H = 5;
  localparam int L = 1;
  function logic [4:0] f(logic [7:0] d);
    return d[H:L];
  endfunction
endclass
module dut(output logic [4:0] o);
  C c = new;
  initial o = c.f(8'h5a);
endmodule
