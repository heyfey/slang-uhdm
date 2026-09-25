// § callFoldFormalBitSelLoc144
package p;
  function automatic logic first(input logic [1:0] x);
    return x[1];
  endfunction
endpackage
module dut(output logic o);
  assign o = p::first(2'b10);
endmodule
