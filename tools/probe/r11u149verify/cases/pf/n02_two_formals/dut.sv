// § callFoldFormalBitSelLoc144
module dut(output logic o);
  function automatic logic pick(input logic [3:0] a, input logic [3:0] b);
    return b[2];
  endfunction
  assign o = pick(4'h1, 4'h4);
endmodule
