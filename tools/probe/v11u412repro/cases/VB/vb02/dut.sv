// § bitSignedElabVar412
module top(output logic [7:0] o);
  function automatic logic [7:0] f(input logic [3:0] i);
    bit signed [3:0] t;
    t = i;
    return t;
  endfunction
  assign o = f(4'b1000);
endmodule
