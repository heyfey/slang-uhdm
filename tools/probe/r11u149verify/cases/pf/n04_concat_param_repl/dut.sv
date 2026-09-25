// § callFoldFormalBitSelLoc144
package p;
  parameter logic [3:0] C = {2'b10, 2'b01};
endpackage
module dut(output logic o);
  function automatic logic b2(input logic [3:0] x);
    return x[2];
  endfunction
  assign o = b2(p::C);
endmodule
