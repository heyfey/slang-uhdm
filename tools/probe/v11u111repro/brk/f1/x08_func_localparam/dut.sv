package q;
  typedef logic [3:0] mask_t;
endpackage
module dut (input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] a);
    localparam q::mask_t K = 4'h5;
    return a ^ K;
  endfunction
  assign o = f(i);
endmodule
