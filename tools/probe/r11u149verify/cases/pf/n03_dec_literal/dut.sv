// § callFoldFormalBitSelLoc144
module dut(output logic o);
  function automatic logic lsb(input logic [7:0] x);
    return x[0];
  endfunction
  assign o = lsb(5);
endmodule
