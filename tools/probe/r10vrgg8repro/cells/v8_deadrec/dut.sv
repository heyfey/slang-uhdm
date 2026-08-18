// LEGAL, TERMINATING SV: the recursive branch is DEAD at the only instance
// (PD=1), so nothing ever recurses at run time.  Only a replay that reads the
// DECLARATION default (PD=0) walks into it.
module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return '1;
    end
    else begin
      return f(address);
    end
  endfunction
  assign o = f(a);
endmodule
module dut(input logic [7:0] a, output logic o);
  m #(.PD(1)) u0(.a(a), .o(o));
endmodule
