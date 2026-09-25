// ARR: inside a function body (the function arm is above the body begin).
module top(input logic a, output logic [3:0] y);
  logic [3:0] v;
  function automatic logic [3:0] f(input logic x);
    logic [3:0] t;
    t[0] = x;
    t[3:1] = 3'b0;
    return t;
  endfunction
  always_comb begin
    v[1] = a;
    y = f(a) ^ v;
  end
endmodule
