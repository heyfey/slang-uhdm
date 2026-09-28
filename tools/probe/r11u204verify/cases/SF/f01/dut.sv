// § tfFormalTdCloneFile196: formals of module functions and a task typed by package typedefs declared in ANOTHER root file (args: defs.sv dut.sv)
module top(input logic [7:0] a, output logic [7:0] o);
  import p::*;
  function automatic byte_t inv(input byte_t x, input tri_t s);
    return ~x >> s;
  endfunction
  task automatic tk(input byte_t x, output byte_t y);
    y = x;
  endtask
  assign o = inv(a, 3'd1);
endmodule
